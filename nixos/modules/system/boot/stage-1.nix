# This module builds the initial ramdisk, which contains an init
# script that performs the first stage of booting the system: it loads
# the modules necessary to mount the root file system, then calls the
# init in the root file system to start the second boot stage.

{ config, lib, pkgs, ... }:

with lib;

let

  udev = config.systemd.package;

  kernelPackages = config.boot.kernelPackages;
  modulesTree = config.system.modulesTree;


  # Determine the set of modules that we need to mount the root FS.
  modulesClosure = pkgs.makeModulesClosure {
    rootModules = config.boot.initrd.availableKernelModules ++ config.boot.initrd.kernelModules;
    kernel = modulesTree;
    allowMissing = true;
  };


  # Some additional utilities needed in stage 1, like mount, lvm, fsck
  # etc.  We don't want to bring in all of those packages, so we just
  # copy what we need.  Instead of using statically linked binaries,
  # we just copy what we need from Glibc and use patchelf to make it
  # work.
  extraUtils = pkgs.runCommand "extra-utils"
    { buildInputs = [pkgs.nukeReferences];
      allowedReferences = [ "out" ]; # prevent accidents like glibc being included in the initrd
    }
    ''
      set +o pipefail

      mkdir -p $out/bin $out/lib
      ln -s $out/bin $out/sbin

      copy_bin_and_libs () {
        [ -f "$out/bin/$(basename $1)" ] && rm "$out/bin/$(basename $1)"
        cp -pdv $1 $out/bin
      }

      # Copy BusyBox.
      for BIN in ${pkgs.busybox}/{s,}bin/*; do
        copy_bin_and_libs $BIN
      done

      # Copy some utillinux stuff.
      copy_bin_and_libs ${pkgs.util-linux_full}/bin/blkid

      # Copy dmsetup and lvm.
      copy_bin_and_libs ${pkgs.lvm2}/bin/dmsetup
      copy_bin_and_libs ${pkgs.lvm2}/bin/lvm

      # Add RAID mdadm tool.
      copy_bin_and_libs ${pkgs.mdadm}/bin/mdadm
      copy_bin_and_libs ${pkgs.mdadm}/bin/mdmon

      # Copy udev.
      copy_bin_and_libs ${udev}/lib/systemd/systemd-udevd
      copy_bin_and_libs ${udev}/bin/udevadm
      for BIN in ${udev}/lib/udev/*_id; do
        copy_bin_and_libs $BIN
      done

      # Copy modprobe.
      copy_bin_and_libs ${pkgs.kmod}/bin/kmod
      ln -sf kmod $out/bin/modprobe

      # Copy resize2fs if needed.
      ${optionalString (any (fs: fs.autoResize) (attrValues config.fileSystems)) ''
        # We need mke2fs in the initrd.
        copy_bin_and_libs ${pkgs.e2fsprogs}/bin/resize2fs
      ''}

      ${config.boot.initrd.extraUtilsCommands}

      # Copy ld manually since it isn't detected correctly
      cp -pv ${pkgs.glibc}/lib/ld*.so.? $out/lib

      # Copy all of the needed libraries for the binaries
      for BIN in $(find $out/{bin,sbin} -type f); do
        echo "Copying libs for bin $BIN"
        LDD="$(ldd $BIN)" || continue
        LIBS="$(echo "$LDD" | awk '{print $3}' | sed '/^$/d')"
        for LIB in $LIBS; do
          [ ! -f "$out/lib/$(basename $LIB)" ] && cp -pdv $LIB $out/lib
          while [ "$(readlink $LIB)" != "" ]; do
            LINK="$(readlink $LIB)"
            if [ "${LINK:0:1}" != "/" ]; then
              LINK="$(dirname $LIB)/$LINK"
            fi
            LIB="$LINK"
            [ ! -f "$out/lib/$(basename $LIB)" ] && cp -pdv $LIB $out/lib
          done
        done
      done

      # Strip binaries further than normal.
      chmod -R u+w $out
      stripDirs "lib bin" "-s"

      # Run patchelf to make the programs refer to the copied libraries.
      for i in $out/bin/* $out/lib/*; do if ! test -L $i; then nuke-refs -e $out $i; fi; done

      for exe in "$out"/bin/* "$out"/lib/*; do
        if [ ! -f "$exe" ] || [ -h "$exe" ]; then
          continue
        fi
        echo "Maybe patching: $exe"
        local patchelfArgs=()
        local stdout
        if stdout="$(patchelf --print-interpreter "$exe" 2>/dev/null)" && [ -n "$stdout" ]; then
          patchelfArgs+=('--set-interpreter' "$out"/lib/ld*.so.?)
        fi
        if stdout="$(patchelf --print-rpath "$exe" 2>/dev/null)" && [ -n "$stdout" ]; then
          patchelfArgs+=('--set-rpath' "$out"/lib)
        fi
        if [ "''${#patchelfArgs[@]}" -gt 0 ]; then
          echo "Patching $exe..."
          ${pkgs.patchelf_old}/bin/patchelf "''${patchelfArgs[@]}" "$exe"
        fi
      done

      check_test_string() {
        if [ "$1" == "$2" ] ; then
          echo 'test passed'
        else
          echo 'test failed'
          # Allow running command for additional debug information
          eval $3
          return 1
        fi
      }

      # Make sure that the patchelf'ed binaries still work.
      echo "testing patched programs..."

      echo 'TESTING: ash'
      TEST_ASH="$(
        $out/bin/ash -c 'echo hello world' | grep -o "hello world" || :
      )"
      check_test_string 'hello world' "$TEST_ASH"

      echo 'TESTING: mount'
      TEST_MOUNT="$($out/bin/mount --help 2>&1 | grep -o "BusyBox" || :)"
      check_test_string 'BusyBox' "$TEST_MOUNT" "$out/bin/mount --help"

      echo 'TESTING: blkid'
      TEST_BLKID="$($out/bin/blkid --help 2>&1 | grep -o 'blkid(8)' || :)"
      check_test_string 'blkid(8)' "$TEST_BLKID" "$out/bin/blkid --help"

      echo 'TESTING: udevadm'
      $out/bin/udevadm --version

      echo 'TESTING: modprobe'
      $out/bin/modprobe --version

      echo 'TESTING: dmsetup'
      TEST_DMSETUP="$(
        $out/bin/dmsetup --version 2>&1 | tee -a log | grep -o "version:" || :
      )"
      check_test_string 'version:' "$TEST_DMSETUP" "$out/bin/dmsetup --version"

      echo 'TESTING: lvm'
      TEST_LVM="$(
        LVM_SYSTEM_DIR="$out" \
          $out/bin/lvm version 2>&1 | tee -a log | grep -o "LVM" || :
      )"
      check_test_string 'LVM' "$TEST_LVM" "$out/bin/lvm version"

      echo 'TESTING: mdadm'
      $out/bin/mdadm --version

      echo 'running boot.initrd.extraUtilsCommandsTest'
      ${config.boot.initrd.extraUtilsCommandsTest}
    ''; # */


  # The initrd only has to mount / or any FS marked as necessary for
  # booting (such as the FS containing /nix/store, or an FS needed for
  # mounting /, like / on a loopback).
  fileSystems = filter
    (fs: fs.neededForBoot || elem fs.mountPoint [ "/" "/nix" "/nix/store" "/var" "/var/log" "/var/lib" "/etc" ])
    (attrValues config.fileSystems);


  udevRules = pkgs.stdenv.mkDerivation {
    name = "udev-rules";
    allowedReferences = [ extraUtils ];
    buildCommand = ''
      mkdir -p $out

      echo 'ENV{LD_LIBRARY_PATH}="${extraUtils}/lib"' > $out/00-env.rules

      cp -v ${udev}/lib/udev/rules.d/60-cdrom_id.rules $out/
      cp -v ${udev}/lib/udev/rules.d/60-persistent-storage.rules $out/
      cp -v ${udev}/lib/udev/rules.d/80-drivers.rules $out/
      cp -v ${pkgs.lvm2}/lib/udev/rules.d/*.rules $out/
      ${config.boot.initrd.extraUdevRulesCommands}

      for i in $out/*.rules; do
          substituteInPlace $i \
            --replace ata_id ${extraUtils}/bin/ata_id \
            --replace scsi_id ${extraUtils}/bin/scsi_id \
            --replace cdrom_id ${extraUtils}/bin/cdrom_id \
            --replace ${pkgs.util-linux_full}/sbin/blkid ${extraUtils}/bin/blkid \
            --replace /sbin/blkid ${extraUtils}/bin/blkid \
            --replace ${pkgs.lvm2}/sbin ${extraUtils}/bin \
            --replace /sbin/mdadm ${extraUtils}/bin/mdadm \
            --replace /bin/sh ${extraUtils}/bin/sh \
            --replace /usr/bin/readlink ${extraUtils}/bin/readlink \
            --replace /usr/bin/basename ${extraUtils}/bin/basename
      done

      # Work around a bug in QEMU, which doesn't implement the "READ
      # DISC INFORMATION" SCSI command:
      #   https://bugzilla.redhat.com/show_bug.cgi?id=609049
      # As a result, `cdrom_id' doesn't print
      # ID_CDROM_MEDIA_TRACK_COUNT_DATA, which in turn prevents the
      # /dev/disk/by-label symlinks from being created.  We need these
      # in the Triton installation CD, so use ID_CDROM_MEDIA in the
      # corresponding udev rules for now.  This was the behaviour in
      # udev <= 154.  See also
      #   http://www.spinics.net/lists/hotplug/msg03935.html
      substituteInPlace $out/60-persistent-storage.rules \
        --replace ID_CDROM_MEDIA_TRACK_COUNT_DATA ID_CDROM_MEDIA
    ''; # */
  };


  # The binary keymap for busybox to load at boot.
  busyboxKeymap = pkgs.runCommand "boottime-keymap"
    { preferLocalBuild = true; }
    ''
      ${pkgs.kbd}/bin/loadkeys -qb "${config.i18n.consoleKeyMap}" > $out ||
        ${pkgs.kbd}/bin/loadkeys -qbu "${config.i18n.consoleKeyMap}" > $out
    '';


  # The init script of boot stage 1 (loading kernel modules for
  # mounting the root FS).
  bootStage1 = pkgs.substituteAll {
    src = ./stage-1-init.sh;

    shell = "${extraUtils}/bin/ash";

    isExecutable = true;

    inherit udevRules extraUtils modulesClosure busyboxKeymap;

    inherit (config.boot) resumeDevice devSize runSize;

    inherit (config.boot.initrd) checkJournalingFS
      preLVMCommands preDeviceCommands postDeviceCommands postMountCommands preFailCommands kernelModules;

    resumeDevices = map (sd: if sd ? device then sd.device else "/dev/disk/by-label/${sd.label}")
                    (filter (sd: (sd ? label || hasPrefix "/dev/" sd.device) && !sd.randomEncryption) config.swapDevices);

    fsInfo =
      let f = fs: [ fs.mountPoint (if fs.device != null then fs.device else "/dev/disk/by-label/${fs.label}") fs.fsType (builtins.concatStringsSep "," fs.options) ];
      in pkgs.writeText "initrd-fsinfo" (concatStringsSep "\n" (concatMap f fileSystems));

    setHostId = optionalString (config.networking.hostId != null) ''
      hi="${config.networking.hostId}"
      ${if elem config.nixpkgs.targetSystem platforms.big-endian then ''
        echo -ne "\x''${hi:0:2}\x''${hi:2:2}\x''${hi:4:2}\x''${hi:6:2}" > /etc/hostid
      '' else ''
        echo -ne "\x''${hi:6:2}\x''${hi:4:2}\x''${hi:2:2}\x''${hi:0:2}" > /etc/hostid
      ''}
    '';
  };


  # The closure of the init script of boot stage 1 is what we put in
  # the initial RAM disk.
  initialRamdisk = pkgs.makeInitrd {
    inherit (config.boot.initrd) compressor prepend;

    contents =
      [ { object = bootStage1;
          symlink = "/init";
        }
        { object = pkgs.writeText "mdadm.conf" config.boot.initrd.mdadmConf;
          symlink = "/etc/mdadm.conf";
        }
        { object = pkgs.stdenv.mkDerivation {
            name = "initrd-${pkgs.kmod-blacklist-ubuntu.name}";
            # Remove all of the logic for re-enabling iwlwifi as it has hardcoded
            # paths in it
            buildCommand = ''
              ${pkgs.perl}/bin/perl -0pe 's/## file: iwlwifi.conf(.+?)##/##/s;' \
                ${pkgs.kmod-blacklist-ubuntu.file} > $out
            '';
          };
          symlink = "/etc/modprobe.d/blacklist.conf";
        }
        { object = pkgs.kmod-debian-aliases.file;
          symlink = "/etc/modprobe.d/aliases.conf";
        }
      ];
  };

in

{
  options = {

    boot.resumeDevice = mkOption {
      type = types.str;
      default = "";
      example = "/dev/sda3";
      description = ''
        Device for manual resume attempt during boot. This should be used primarily
        if you want to resume from file. If left empty, the swap partitions are used.
        Specify here the device where the file resides.
        You should also use <varname>boot.kernelParams</varname> to specify
        <literal><replaceable>resume_offset</replaceable></literal>.
      '';
    };

    boot.initrd.prepend = mkOption {
      default = [ ];
      type = types.listOf types.str;
      description = ''
        Other initrd files to prepend to the final initrd we are building.
      '';
    };

    boot.initrd.checkJournalingFS = mkOption {
      default = true;
      type = types.bool;
      description = ''
        Whether to run <command>fsck</command> on journaling filesystems such as ext3.
      '';
    };

    boot.initrd.mdadmConf = mkOption {
      default = "";
      type = types.lines;
      description = ''
        Contents of <filename>/etc/mdadm.conf</filename> in stage 1.
      '';
    };

    boot.initrd.preLVMCommands = mkOption {
      default = "";
      type = types.lines;
      description = ''
        Shell commands to be executed immediately before LVM discovery.
      '';
    };

    boot.initrd.preDeviceCommands = mkOption {
      default = "";
      type = types.lines;
      description = ''
        Shell commands to be executed before udev is started to create
        device nodes.
      '';
    };

    boot.initrd.postDeviceCommands = mkOption {
      default = "";
      type = types.lines;
      description = ''
        Shell commands to be executed immediately after stage 1 of the
        boot has loaded kernel modules and created device nodes in
        <filename>/dev</filename>.
      '';
    };

    boot.initrd.postMountCommands = mkOption {
      default = "";
      type = types.lines;
      description = ''
        Shell commands to be executed immediately after the stage 1
        filesystems have been mounted.
      '';
    };

    boot.initrd.preFailCommands = mkOption {
      default = "";
      type = types.lines;
      description = ''
        Shell commands to be executed before the failure prompt is shown.
      '';
    };

    boot.initrd.extraUtilsCommands = mkOption {
      internal = true;
      default = "";
      type = types.lines;
      description = ''
        Shell commands to be executed in the builder of the
        extra-utils derivation.  This can be used to provide
        additional utilities in the initial ramdisk.
      '';
    };

    boot.initrd.extraUtilsCommandsTest = mkOption {
      internal = true;
      default = "";
      type = types.lines;
      description = ''
        Shell commands to be executed in the builder of the
        extra-utils derivation after patchelf has done its
        job.  This can be used to test additional utilities
        copied in extraUtilsCommands.
      '';
    };

    boot.initrd.extraUdevRulesCommands = mkOption {
      internal = true;
      default = "";
      type = types.lines;
      description = ''
        Shell commands to be executed in the builder of the
        udev-rules derivation.  This can be used to add
        additional udev rules in the initial ramdisk.
      '';
    };

    boot.initrd.compressor = mkOption {
      internal = true;
      # We need --check=crc32 since the default crc64 is not supported
      # by the kernel
      default = "xz --check=crc32 -6";
      type = types.str;
      description = "The compressor to use on the initrd image.";
      example = "gzip -9n";
    };

    boot.initrd.supportedFilesystems = mkOption {
      default = [ ];
      example = [ "btrfs" ];
      type = types.listOf types.str;
      description = "Names of supported filesystem types in the initial ramdisk.";
    };

    fileSystems = mkOption {
      options.neededForBoot = mkOption {
        default = false;
        type = types.bool;
        description = ''
          If set, this file system will be mounted in the initial
          ramdisk.  By default, this applies to the root file system
          and to the file system containing
          <filename>/nix/store</filename>.
        '';
      };
    };

  };

  config = mkIf (!config.boot.isContainer) {

    assertions = [
      { assertion = any (fs: fs.mountPoint == "/") (attrValues config.fileSystems);
        message = "The ‘fileSystems’ option does not specify your root file system.";
      }
      { assertion = let inherit (config.boot) resumeDevice; in
          resumeDevice == "" || builtins.substring 0 1 resumeDevice == "/";
        message = "boot.resumeDevice has to be an absolute path."
          + " Old \"x:y\" style is no longer supported.";
      }
    ];

    # We want to make sure we cache all of the dependencies needed for
    # rebuilding the initrd locally
    system.extraDependencies = [
      pkgs.busybox
      pkgs.stdenv
    ] ++ initialRamdisk.buildInputs
      ++ initialRamdisk.nativeBuildInputs;

    system.build.bootStage1 = bootStage1;
    system.build.initialRamdisk = initialRamdisk;
    system.build.extraUtils = extraUtils;

    system.requiredKernelConfig = with config.lib.kernelConfig; [
      (isYes "TMPFS")
      (isYes "BLK_DEV_INITRD")
    ];

    boot.initrd.supportedFilesystems = map (fs: fs.fsType) fileSystems;

  };
}
