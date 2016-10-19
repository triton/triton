{ stdenv, fetchFromGitHub, autoreconfHook, util-linux_full, nukeReferences, coreutils, systemd_lib, lvm2
, configFile ? "all"

# Userspace dependencies
, zlib, attr, python

# Kernel dependencies
, kernel ? null, spl ? null

# Version specific settings
, version, src, patches, maxKernelVersion
, ...
}:

with stdenv.lib;
let
  buildKernel = any (n: n == configFile) [ "kernel" "all" ];
  buildUser = any (n: n == configFile) [ "user" "all" ];
in

assert any (n: n == configFile) [ "kernel" "user" "all" ];
assert buildKernel -> kernel != null && spl != null;

assert kernel != null -> versionOlder kernel.version maxKernelVersion
  || throw "SPL ${version} is too old for kernel ${kernel.version}";

stdenv.mkDerivation rec {
  name = "zfs-${configFile}-${version}${optionalString buildKernel "-${kernel.version}"}";

  inherit version src patches;

  buildInputs = [ autoreconfHook nukeReferences ]
    ++ optionals buildKernel [ spl ]
    ++ optionals buildUser [ zlib attr util-linux_full systemd_lib lvm2 python ];

  # for zdb to get the rpath to libgcc_s, needed for pthread_cancel to work
  NIX_CFLAGS_LINK = "-lgcc_s";

  preConfigure = ''
    substituteInPlace ./module/zfs/zfs_ctldir.c   --replace "umount -t zfs"           "${util-linux_full}/bin/umount -t zfs"
    substituteInPlace ./module/zfs/zfs_ctldir.c   --replace "mount -t zfs"            "${util-linux_full}/bin/mount -t zfs"
    substituteInPlace ./lib/libzfs/libzfs_mount.c --replace "/bin/umount"             "${util-linux_full}/bin/umount"
    substituteInPlace ./lib/libzfs/libzfs_mount.c --replace "/bin/mount"              "${util-linux_full}/bin/mount"
    substituteInPlace ./udev/rules.d/*            --replace "/lib/udev/vdev_id"       "$out/lib/udev/vdev_id"
    substituteInPlace ./cmd/ztest/ztest.c         --replace "/usr/sbin/ztest"         "$out/sbin/ztest"
    substituteInPlace ./cmd/ztest/ztest.c         --replace "/usr/sbin/zdb"           "$out/sbin/zdb"
    substituteInPlace ./config/user-systemd.m4    --replace "/usr/lib/modules-load.d" "$out/etc/modules-load.d"
    substituteInPlace ./config/zfs-build.m4       --replace "\$sysconfdir/init.d"     "$out/etc/init.d"
    substituteInPlace ./etc/zfs/Makefile.am       --replace "\$(sysconfdir)"          "$out/etc"
    substituteInPlace ./cmd/zed/Makefile.am       --replace "\$(sysconfdir)"          "$out/etc"
    substituteInPlace ./module/Makefile.in        --replace "/bin/cp"                 "cp"
    substituteInPlace ./etc/systemd/system/zfs-share.service.in \
        --replace "@bindir@/rm " "${coreutils}/bin/rm "
    ./autogen.sh
  '';

  configureFlags = [
    "--with-config=${configFile}"
  ] ++ optionals buildUser [
    "--with-dracutdir=$(out)/lib/dracut"
    "--with-udevdir=$(out)/lib/udev"
    "--with-systemdunitdir=$(out)/etc/systemd/system"
    "--with-systemdpresetdir=$(out)/etc/systemd/system-preset"
    "--with-mounthelperdir=$(out)/bin"
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--enable-systemd"
  ] ++ optionals buildKernel [
    "--with-spl=${spl}/libexec/spl"
    "--with-linux=${kernel.dev}/lib/modules/${kernel.modDirVersion}/source"
    "--with-linux-obj=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
  ];

  installFlags = [
    "sysconfdir=\${out}/etc"
    "DEFAULT_INITCONF_DIR=\${out}/etc/default"
  ];

  postInstall = ''
    # Prevent kernel modules from depending on the Linux -dev output.
    nuke-refs $(find $out -name "*.ko")
  '' + optionalString buildUser ''
    # Remove provided services as they are buggy
    rm $out/etc/systemd/system/zfs-import-*.service

    rm -r $out/share/zfs

    sed -i '/zfs-import-scan.service/d' $out/etc/systemd/system/*

    for i in $out/etc/systemd/system/*; do
      substituteInPlace $i --replace "zfs-import-cache.service" "zfs-import.target"
    done

    # Fix pkgconfig.
    ln -s ../share/pkgconfig $out/lib/pkgconfig
  '';

  # We don't want these compiler security features / optimizations
  # when we are building kernel modules
  optFlags = !buildKernel;
  pie = !buildKernel;
  fpic = !buildKernel;
  noStrictOverflow = !buildKernel;
  fortifySource = !buildKernel;
  stackProtector = !buildKernel;
  optimize = !buildKernel;

  passthru = {
    inherit maxKernelVersion;
  };

  meta = {
    description = "ZFS Filesystem Linux Kernel module";
    homepage = http://zfsonlinux.org/;
    license = licenses.cddl;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
