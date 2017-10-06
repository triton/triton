{ stdenv
, docbook_xml_dtd_42
, docbook_xml_dtd_45
, docbook-xsl
, fetchFromGitHub
, fetchTritonPatch
, gettext
, gnum4
, gperf
, intltool
, libxslt
, meson
, ninja
, python3Packages

, acl
, audit_lib
, bzip2
, cryptsetup
, curl
, elfutils
, gnu-efi
, gnutls
, iptables
, kmod
, libcap
, libgcrypt
, libgpg-error
, libidn2
, libmicrohttpd
, libseccomp
, libxkbcommon
, linux-headers_triton
, lz4
, pam
, polkit
, qrencode
, systemd_lib
, util-linux_lib
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

  version = "235";
in
stdenv.mkDerivation rec {
  name = "${type}systemd-${version}";

  src = fetchFromGitHub {
    version = 3;
    owner = "systemd";
    repo = "systemd";
    rev = "v${version}";
    sha256 = "6b4bd7f791be822432ce5e05f38ea06d99f78d0965215144d6204d8712b725ec";
  };

  nativeBuildInputs = [
    gnum4
    gperf
    meson
    ninja
    python3Packages.python
  ] ++ optionals (!libOnly) [
    docbook_xml_dtd_42
    docbook_xml_dtd_45
    docbook-xsl
    gettext
    intltool
    libxslt
    python3Packages.lxml
  ];

  buildInputs = [
    libcap
    libgcrypt
    libgpg-error
    lz4
    util-linux_lib
    xz
  ] ++ optionals (!libOnly) [
    acl
    audit_lib
    bzip2
    curl
    cryptsetup
    elfutils-libs
    gnutls
    iptables
    kmod
    libidn2
    libmicrohttpd
    libseccomp
    libxkbcommon
    linux-headers_triton
    pam
    polkit
    qrencode
    zlib
  ];

  patches = [
    (fetchTritonPatch {
      rev = "7e1e315fce1d7a94ab870060b4f3314f5e6254df";
      file = "s/systemd/0001-Fixup-paths.patch";
      sha256 = "6a979c74b824967b6c998b9c16c5900276a1706ed486d58789fa3d2e431e4af4";
    })
  ];

  postPatch = optionalString libOnly ''
    # Keep only libs in the build
    sed \
      -e '/public_programs = \[\]/q' \
      -e "\#subdir('\(po\|catalog\|src/login\)')#d" \
      -i meson.build

    # Make sure we build libudev
    echo "subdir('src/libudev')" >> meson.build
  '' + ''
    # Fix sysconfdir
    sed -i "/sysconfdir = /s,prefixdir,'/'," meson.build

    # Patchup scripts
    patchShebangs src/basic/generate-gperfs.py
  '' + optionalString (!libOnly) ''
    patchShebangs src/resolve/generate-dns_type-gperf.py
    patchShebangs tools/make-directive-index.py
    patchShebangs tools/make-man-index.py
    patchShebangs tools/xml_helper.py

    # Disable building any tests
    sed \
      -e '/^[ \t]*foreach.*tests/,/endforeach/d' \
      -e '/^[ \t]*test_.*executable(/,/)/d' \
      -e '/^[ \t]*test(/,/)/d' \
      -e "\#subdir('\(src/\|\)test')#d" \
      -i meson.build
  '';

  preConfigure = ''
    mesonFlagsArray+=(
      "-Dprefix=$out"
      "-Drootprefix=/run/current-system/module/systemd"
    )
  '' + optionalString (!libOnly) ''
    # Make sure our rpath has enough space for our dependency rewriting
    export NIX_LDFLAGS="$NIX_LDFLAGS -rpath ${systemd_lib}/lib -rpath $out/lib/systemd"
  '';

  mesonFlags = [
    "-Dtelinit-path=/run/current/system/sw/bin/telinit"
    "-Dquotaon-path=/run/current/system/sw/bin/quotaon"
    "-Dquotacheck-path=/run/current/system/sw/bin/quotacheck"
    "-Dkill-path=/run/current/system/sw/bin/kill"
    "-Dkmod-path=/run/current/system/sw/bin/kmod"
    "-Dkexec-path=/run/current/system/sw/bin/kexec"
    "-Dsulogin-path=/run/current/system/sw/bin/sulogin"
    "-Dmount-path=/run/current/system/sw/bin/mount"
    "-Dumount-path=/run/current/system/sw/bin/umount"
    "-Dloadkeys-path=/run/current/system/sw/bin/loadkeys"
    "-Dsetfont-path=/run/current/system/sw/bin/setfont"
    "-Dsystem-uid-max=999"
    "-Dsystem-gid-max=999"
  ] ++ optionals libOnly [
    "-Ddefault-dnssec=no"
  ] ++ optionals (!libOnly) [
    "-Dremote=true"
    "-Dimportd=true"
    "-Dman=true"
    "-Dfallback-hostname=triton"
    "-Ddefault-hierarchy=unified"
    "-Dseccomp=true"
    "-Dselinux=false"
    "-Dapparmor=false"
    "-Dpolkit=true"
    "-Dacl=true"
    "-Daudit=true"
    "-Dblkid=true"
    "-Dkmod=true"
    "-Dpam=true"
    "-Dmicrohttpd=true"
    "-Dlibcryptsetup=true"
    "-Dlibcurl=true"
    "-Dlibidn2=true"
    "-Dlibidn=false"
    "-Dlibiptc=true"
    "-Dqrencode=true"
    "-Dgcrypt=true"
    "-Dgnutls=true"
    "-Delfutils=true"
    "-Dzlib=true"
    "-Dbzip2=true"
    "-Dxz=true"
    "-Dlz4=true"
    "-Dxkbcommon=true"
    "-Dglib=false"  # TEST only
    "-Ddbus=false"  # TEST only
    "-Dgnu-efi=true"
    "-Defi-libdir=${gnu-efi}/lib"
    "-Defi-includedir=${gnu-efi}/include/efi"
  ];

  postConfigure = ''
    # Fix directory impurities
    sed -i "s,\"$TMPDIR,\"/no-such-path,g" config.h

    # Use mutable paths for enabling services at runtime
    sed -i '/UNIT_PATH/s,/etc/systemd,/etc/systemd-mutable,' config.h
  '';

  preInstall = ''
    export DESTDIR="$out"
  '';

  postInstall = ''
    rm -r "$out"/var
  '' + optionalString libOnly ''
    rm -r "$out"/etc
  '' + ''
    dir="$out"
    mv "$out$dir"/* "$out"
    while [ "$dir" != "/" ]; do
      rmdir "$out$dir"
      dir="$(dirname "$dir")"
    done

    merge() {
      local tgt="$1"
      local dst="$2"

      local f
      for f in $(ls "$tgt"); do
        if [ -d "$tgt/$f" ] && [ -d "$dst/$f" ]; then
          merge "$tgt/$f" "$dst/$f"
        else
          mv "$tgt/$f" "$dst/$f"
        fi
      done

      rmdir "$tgt"
    }
    merge "$out"/run/current-system/module/systemd "$out"
    rmdir "$out"/run/current-system/module
    rmdir "$out"/run/current-system
    rmdir "$out"/run
  '' + optionalString (!libOnly) ''
    # Remove libraries shared by libsystemd
    for lib in ${systemd_lib}/lib/*.so*; do
      rm "$out"/lib/$(basename "$lib")
    done
    rm -r "$out"/{share,lib}/pkgconfig

    # Remove unused stuff
    rm -r "$out"/lib/rpm
    rm "$out"/bin/kernel-install

    # Create compat symlinks for SysV commands
    for i in init halt poweroff runlevel reboot shutdown; do
      ln -s systemctl "$out"/bin/$i
    done
  '';

  preFixupCheck = optionalString libOnly ''
    # We should only have include and lib
    ! ls "$out" | grep -v '\(include\|lib\)'
  '' + optionalString (!libOnly) ''
    ! test -d "$out"/run
  '';

  # The interface version prevents NixOS from switching to an
  # incompatible systemd at runtime.  (Switching across reboots is
  # fine, of course.)  It should be increased whenever systemd changes
  # in a backwards-incompatible way.  If the interface version of two
  # systemd builds is the same, then we can switch between them at
  # runtime; otherwise we can't and we need to reboot.
  passthru.interfaceVersion = 4;

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
