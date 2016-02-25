{ stdenv
, autoconf
, automake
, fetchFromGitHub
, gettext
, gnum4
, intltool
, libtool
, libxslt
, perl

, acl
, audit_lib
, bzip2
, coreutils
, cryptsetup
, curl
, docbook_xml_dtd_42
, docbook_xml_dtd_45
, docbook_xsl
, elfutils
, gnu-efi
, gnutls
, gperf
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
  libOnly = type == "lib";

  elfutils-libs = stdenv.mkDerivation {
    name = "elfutils-libs-${elfutils.version}";

    buildCommand = ''
      mkdir -p $out
      ln -sv ${elfutils}/{lib,include} $out
    '';
  };

  inherit (stdenv.lib)
    optionals
    optionalString;
in
stdenv.mkDerivation rec {
  version = "229";
  name = "${type}systemd-${version}";

  src = fetchFromGitHub {
    owner = "NixOS";
    repo = "systemd";
    rev = "4936f6e6c05162516a685ebd227b55816cf2b670";
    sha256 = "1q0pyrljmq73qcan9rfqsiw66l1g159m5in5qgb8zwlwhl928670";
  };

  nativeBuildInputs = [
    autoconf
    automake
    gnum4
    intltool
    libtool
    perl
  ] ++ optionals (!libOnly) [
    docbook_xsl
    docbook_xml_dtd_42
    docbook_xml_dtd_45
    gettext
    libxslt
  ];

  buildInputs = [
    gperf
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

  preConfigure = optionalString (!libOnly) ''
    # FIXME: patch this in systemd properly (and send upstream).
    for i in src/remount-fs/remount-fs.c src/core/mount.c src/core/swap.c src/fsck/fsck.c units/emergency.service.in units/rescue.service.in src/journal/cat.c src/core/shutdown.c src/nspawn/nspawn.c src/shared/generator.c; do
      test -e $i
      substituteInPlace $i \
        --replace /usr/bin/getent ${stdenv.cc.libc}/bin/getent \
        --replace /bin/mount ${util-linux_full}/bin/mount \
        --replace /bin/umount ${util-linux_full}/bin/umount \
        --replace /sbin/swapon ${util-linux_full}/sbin/swapon \
        --replace /sbin/swapoff ${util-linux_full}/sbin/swapoff \
        --replace /bin/echo ${coreutils}/bin/echo \
        --replace /bin/cat ${coreutils}/bin/cat \
        --replace /sbin/sulogin ${util-linux_full}/sbin/sulogin \
        --replace /usr/lib/systemd/systemd-fsck $out/lib/systemd/systemd-fsck
    done

    substituteInPlace src/journal/catalog.c \
      --replace /usr/lib/systemd/catalog/ $out/lib/systemd/catalog/
  '' + ''
    configureFlagsArray+=(
      "--with-rootprefix=$out"
      "--with-dbuspolicydir=$out/etc/dbus-1/system.d"
      "--with-dbussessionservicedir=$out/share/dbus-1/services"
      "--with-dbussystemservicedir=$out/share/dbus-1/system-services"
    )

    ./autogen.sh
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
    "--disable-kdbus" # We can't enable this since bus1 is a thing now
    "--enable-myhostname"
    "--enable-hwdb"
    "--enable-hibernate"
    "--enable-ldconfig"
    "--with-tty-gid=3" # tty in NixOS has gid 3
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
    "--enable-manpages"
    "--with-efi-libdir=${gnu-efi}/lib"
    "--with-efi-ldsdir=${gnu-efi}/lib"
    "--with-efi-includedir=${gnu-efi}/include"
    "--with-kbd-loadkeys=${kbd}/bin/loadkeys"
    "--with-kbd-setfont=${kbd}/bin/setfont"
  ]);

  PYTHON_BINARY = "${coreutils}/bin/env python"; # don't want a build time dependency on Python

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
    echo 'myBuildLibs: $(lib_LTLIBRARIES) udevadm' >> Makefile
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
    "install-libLTLIBRARIES"
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

    # Fix reference to /bin/false in the D-Bus services.
    for i in $out/share/dbus-1/system-services/*.service; do
      substituteInPlace $i --replace /bin/false ${coreutils}/bin/false
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
  passthru.interfaceVersion = 2;

  meta = with stdenv.lib; {
    homepage = "http://www.freedesktop.org/wiki/Software/systemd";
    description = "A system and service manager for Linux";
    licenses = licenses.gpl2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
