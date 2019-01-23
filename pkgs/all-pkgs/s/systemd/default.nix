{ stdenv
, fetchurl
, gettext
, gperf
, gnum4
, intltool
, libxslt
, perl

, acl
, audit_lib
, bzip2
, coreutils_small
, cryptsetup
, curl
, docbook_xml_dtd_42
, docbook_xml_dtd_45
, docbook-xsl
, elfutils
, gnu-efi
, gnutls
, iptables
, kbd
, kmod
, libcap
, libgcrypt
, libgpg-error
, libidn
, libmicrohttpd
, libseccomp
, libxkbcommon
, lz4
, pam
, python3Packages
, qrencode
, util-linux_lib
, util-linux_full
, xz
, zlib

, type ? ""
}:

let
  inherit (stdenv.lib)
    optionals
    optionalString;
in

let
  libOnly = type == "lib";

  elfutils-libs = stdenv.mkDerivation {
    name = "elfutils-libs-${elfutils.version}";

    buildCommand = ''
      mkdir -p $out
      ln -sv ${elfutils}/{lib,include} $out
    '';
  };

  upstreamVersion = "233";
  version = "${upstreamVersion}-9-g265d78708";
in
stdenv.mkDerivation rec {
  name = "${type}systemd-${version}";

  src = fetchurl {
    url = "https://github.com/triton/systemd/releases/download/v${version}/systemd-${upstreamVersion}.tar.xz";
    hashOutput = false;
    sha256 = "b97b453c0b5783d7c90424ca0dd2fb5805f96505a06e0868a39d535abd2906f9";
  };

  nativeBuildInputs = [
    gperf
    gnum4
    intltool
    perl
  ] ++ optionals (!libOnly) [
    docbook-xsl
    docbook_xml_dtd_42
    docbook_xml_dtd_45
    gettext
    libxslt
  ];

  buildInputs = [
    libcap
    xz
    lz4
    libgcrypt
    libgpg-error
    audit_lib
    libidn
  ] ++ optionals (libOnly) [
    util-linux_lib
  ] ++ optionals (!libOnly) [
    python3Packages.python
    python3Packages.lxml
    kmod
    libxkbcommon
    libseccomp
    zlib
    bzip2
    pam
    acl
    elfutils-libs
    cryptsetup
    qrencode
    gnutls
    libmicrohttpd
    curl
    iptables
    gnu-efi
    util-linux_full
  ];

  postPatch = ''
    sed -i 's,\(-DABS_\(SRC\|BUILD\)_DIR=\\"\).*\\",\1/no-such-path\\",g' Makefile.in

    # Fix memfd_create detection
    sed -i '/#include <sched.h>/a#include <sys/mman.h>' configure
    sed -i '1i#include <sys/mman.h>' src/basic/fileio.c
    # Fix getrandom detection
    sed -i '/#include <sched.h>/a#include <sys/random.h>' configure
    sed -i '1i#include <sys/random.h>' src/basic/random-util.c
    # Fix renameat2 detection
    sed -i '/#include <sched.h>/a#include <stdio.h>' configure

    # Xlocale.h not needed
    sed -i '/xlocale.h/d' src/basic/parse-util.c
  '' + optionalString (type != "lib") ''
    # Fix an issue with missing definitions conflicting with real ones
    sed -i '\,#include <sys/socket.h>,i#include <sys/mount.h>' src/basic/missing.h

    # Fix another issue where sys/mount conflicts with linux/fs definitions
    find . \( -name \*.c -or -name \*.h \) -exec sed -i '\,#include <linux/fs.h>,i#include <sys/mount.h>' {} \;
  '';

  preConfigure = ''
    configureFlagsArray+=(
      "--with-rootprefix=$out"
      "--with-dbuspolicydir=$out/etc/dbus-1/system.d"
      "--with-dbussessionservicedir=$out/share/dbus-1/services"
      "--with-dbussystemservicedir=$out/share/dbus-1/system-services"
    )
  '';

  configureFlags = [
    "--localstatedir=/var"
    "--sysconfdir=/etc"

    "--disable-address-sanitizer"  # TODO: Fix, breaks lvm2 invocation
    "--disable-undefined-sanitizer"  # TODO: Fix, breaks lvm2 invocation
    "--enable-utmp"
    "--disable-dbus"  # Only needed in tests which we dont run
    "--disable-coverage"
    "--disable-selinux"
    "--disable-apparmor"
    # "--disable-adm-group"
    # "--disable-wheel-group"
    "--disable-smack"

    "--enable-binfmt"
    "--enable-vconsole"
    "--enable-quotacheck"
    "--enable-tmpfiles"
    "--enable-sysusers"
    "--enable-firstboot"
    "--enable-randomseed"
    "--enable-backlight"
    "--enable-rfkill"
    "--enable-logind"
    # "--without-kill-user-processes"
    "--enable-machined"
    "--enable-importd"
    "--enable-hostnamed"
    "--enable-timedated"
    "--enable-timesyncd"
    "--with-ntp-servers="
    "--enable-localed"
    "--enable-coredump"
    "--enable-polkit"
    "--enable-resolved"
    "--enable-networkd"
    "--enable-efi"
    # "--enable-tpm"
    "--enable-myhostname"
    "--enable-hwdb"
    "--enable-hibernate"
    "--enable-ldconfig"
    "--with-tty-gid=3" # tty in NixOS has gid 3
    "--with-default-hierarchy=unified"
    "--with-fallback-hostname=triton"
    "--disable-split-usr"
    "--disable-tests"
  ] ++ (if libOnly then [
    "--without-python"
    "--disable-kmod"
    "--disable-xkbcommon"
    "--disable-blkid"
    "--disable-seccomp"
    "--disable-ima"
    "--enable-xz"
    "--disable-zlib"
    "--disable-bzip2"
    "--enable-lz4"
    "--disable-pam"
    "--disable-acl"
    "--enable-gcrypt"
    "--enable-audit"
    "--disable-elfutils"
    "--disable-libcryptsetup"
    "--disable-qrencode"
    "--disable-gnutls"
    "--disable-microhttpd"
    "--disable-libcurl"
    "--enable-libidn"
    "--disable-libiptc"
    "--disable-gnuefi"
    "--disable-tpm"
    "--disable-manpages"
  ] else [
    "--with-python"
    "--enable-kmod"
    "--enable-xkbcommon"
    "--enable-blkid"
    "--enable-seccomp"
    "--enable-ima"
    "--enable-xz"
    "--enable-zlib"
    "--enable-bzip2"
    "--enable-lz4"
    "--enable-pam"
    "--enable-acl"
    "--enable-gcrypt"
    "--enable-audit"
    "--enable-elfutils"
    "--enable-libcryptsetup"
    "--enable-gnutls"
    "--enable-microhttpd"
    "--enable-libcurl"
    "--enable-libidn"
    "--enable-libiptc"
    "--enable-gnuefi"
    "--enable-tpm"
    "--enable-manpages"
    "--with-efi-libdir=${gnu-efi}/lib"
    "--with-efi-ldsdir=${gnu-efi}/lib"
    "--with-efi-includedir=${gnu-efi}/include"
    "--with-kbd-loadkeys=${kbd}/bin/loadkeys"
    "--with-kbd-setfont=${kbd}/bin/setfont"
  ]);

  PYTHON_BINARY = "${coreutils_small}/bin/env python"; # don't want a build time dependency on Python

  NIX_CFLAGS_COMPILE = [
    # Can't say ${polkit}/bin/pkttyagent here because that would
    # lead to a cyclic dependency.
    "-UPOLKIT_AGENT_BINARY_PATH"
    "-DPOLKIT_AGENT_BINARY_PATH=\"/run/current-system/sw/bin/pkttyagent\""

    # Set the release_agent on /sys/fs/cgroup/systemd to the
    # currently running systemd (/run/current-system/systemd) so
    # that we don't use an obsolete/garbage-collected release agent.
    "-USYSTEMD_CGROUP_AGENT_PATH"
    "-DSYSTEMD_CGROUP_AGENT_PATH=\"/run/current-system/systemd/lib/systemd/systemd-cgroups-agent\""
    "-USYSTEMD_BINARY_PATH"
    "-DSYSTEMD_BINARY_PATH=\"/run/current-system/systemd/lib/systemd/systemd\""
  ];

  preBuild = optionalString libOnly ''
    echo 'myBuildLibs: $(rootlib_LTLIBRARIES) udevadm' >> Makefile
    echo 'myBuiltSources: $(BUILT_SOURCES)' >> Makefile
    make myBuiltSources
  '';

  buildFlags = optionals libOnly [
    "myBuildLibs"
  ];

  preInstall = ''
    installFlagsArray+=(
      "localstatedir=$TMPDIR/var"
      "sysconfdir=$out/etc"
      "sysvinitdir=$TMPDIR/etc/init.d"
      "pamconfdir=$out/etc/pam.d"
    )
  '';

  installTargets = optionals libOnly [
    "install-includeHEADERS"
    "install-pkgincludeHEADERS"
    "install-rootlibLTLIBRARIES"
    "install-pkgconfiglibDATA"
  ];

  postInstall = optionalString libOnly ''
    # This is unfortunately needed by lvm2 which is a dependency of systemd_full
    mkdir -p $out/bin
    cp udevadm $out/bin
  '' + optionalString (!libOnly) ''
    # sysinit.target: Don't depend on
    # systemd-tmpfiles-setup.service. This interferes with NixOps's
    # send-keys feature (since sshd.service depends indirectly on
    # sysinit.target).
    mv $out/lib/systemd/system/sysinit.target.wants/systemd-tmpfiles-setup-dev.service $out/lib/systemd/system/multi-user.target.wants/

    mkdir -p $out/example/systemd
    mv $out/lib/{modules-load.d,binfmt.d,sysctl.d,tmpfiles.d} $out/example
    mv $out/lib/systemd/{system,user} $out/example/systemd

    rm -rf $out/etc/systemd/system

    # Install SysV compatibility commands.
    mkdir -p $out/sbin
    ln -s $out/lib/systemd/systemd $out/sbin/telinit
    for i in init halt poweroff runlevel reboot shutdown; do
      ln -s $out/bin/systemctl $out/sbin/$i
    done

    # Remove all of the rpm folders
    find $out -name rpm -exec rm -r { } \;

    # "kernel-install" shouldn't be used on NixOS.
    find $out -name "*kernel-install*" -exec rm {} \;
  '';

  # The interface version prevents NixOS from switching to an
  # incompatible systemd at runtime.  (Switching across reboots is
  # fine, of course.)  It should be increased whenever systemd changes
  # in a backwards-incompatible way.  If the interface version of two
  # systemd builds is the same, then we can switch between them at
  # runtime; otherwise we can't and we need to reboot.
  passthru = {
    interfaceVersion = 3;
    inherit upstreamVersion;
  };

  # We can't enable some of these security hardenings due to systemd-boot
  # However, systemd already enables them where it can
  optFlags = false;
  pie = false;
  fpic = false;
  noStrictOverflow = false;
  fortifySource = false;
  stackProtector = false;
  optimize = false;

  meta = with stdenv.lib; {
    homepage = "http://www.freedesktop.org/wiki/Software/systemd";
    description = "A system and service manager for Linux";
    licenses = licenses.gpl2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
