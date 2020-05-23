{ stdenv
, docbook_xml_dtd_42
, docbook_xml_dtd_45
, docbook-xsl
, fetchFromGitHub
, gnum4
, gperf
, libxslt
, meson
, ninja
, python3

, acl
, audit_lib
, bash-completion
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
, libselinux
, libxkbcommon
, lz4
, p11-kit
, pam
, pcre2_lib
, polkit
, qrencode
, systemd_lib
, util-linux_lib
, xz
, zlib
}:

let
  elfutils_libs = stdenv.mkDerivation {
    name = "elfutils-libs-${elfutils.version}";

    buildCommand = ''
      mkdir -p $out
      ln -sv ${elfutils}/{lib,include} $out
    '';
  };

  version = "245.5";
in
stdenv.mkDerivation {
  name = "systemd-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "systemd";
    repo = "systemd-stable";
    rev = "v${version}";
    sha256 = "2694bbe2330b541bd559839513ecf660f5c1e38ea547aab94b706e1686205093";
  };

  nativeBuildInputs = [
    docbook_xml_dtd_42
    docbook_xml_dtd_45
    docbook-xsl
    gnum4
    gperf
    libxslt
    meson
    ninja
    python3
  ];

  buildInputs = [
    acl
    audit_lib
    bash-completion
    bzip2
    cryptsetup
    curl
    elfutils_libs
    gnu-efi
    gnutls
    iptables
    kmod
    libcap
    libgcrypt
    libgpg-error
    libidn2
    libmicrohttpd
    libseccomp
    libselinux
    libxkbcommon
    lz4
    p11-kit
    pam
    pcre2_lib
    polkit
    qrencode
    util-linux_lib
    xz
    zlib
  ];

  NIX_LDFLAGS = "-rpath ${systemd_lib}/lib";

  postPatch = ''
    patchShebangs src/resolve/generate-dns_type-gperf.py
    patchShebangs tools/generate-gperfs.py
    patchShebangs tools/make-autosuspend-rules.py
    patchShebangs tools/xml_helper.py
  '';

  mesonFlags = [
    "-Dversion-tag=${version}"
    "-Drootprefix=/run/current-system/sw"
    "-Dquotaon-path=/run/current-system/sw/bin/quotaon"
    "-Dquotacheck-path=/run/current-system/sw/bin/quotacheck"
    "-Dkmod-path=/run/current-system/sw/bin/kmod"
    "-Dkexec-path=/run/current-system/sw/bin/kexec"
    "-Dsulogin-path=/run/current-system/sw/bin/sulogin"
    "-Dmount-path=/run/current-system/sw/bin/mount"
    "-Dumount-path=/run/current-system/sw/bin/umount"
    "-Dloadkeys-path=/run/current-system/sw/bin/loadkeys"
    "-Dsetfont-path=/run/current-system/sw/bin/setfont"
    "-Dnologin-path=/run/current-system/sw/bin/nologin"
    "-Dldconfig=false"
    "-Dcreate-log-dirs=false"
    "-Dman=true"
    "-Dfallback-hostname=triton"
    "-Dsystem-uid-max=1000"
    "-Dsystem-gid-max=1000"
    "-Dtty-gid=3"
    "-Dusers-gid=100"
    "-Ddefault-locale=C.UTF-8"
    "-Ddns-over-tls=gnutls"
    "-Dlibidn2=true"
    "-Defi-includedir=${gnu-efi}/include/efi"
    "-Defi-libdir=${gnu-efi}/lib"
    "-Dtests=false"
  ];

  preInstall = ''
    export DESTDIR="$out"
  '';

  # We need to work around install locations with the root
  # prefix and dest dir
  postInstall = ''
    dir="$out$out"
    cp -ar "$dir"/* "$out"
    while [ "$dir" != "$out" ]; do
      rm -r "$dir"
      dir="$(dirname "$dir")"
    done
    cp -ar "$out"/run/current-system/sw/* "$out"
    rm -r "$out"/{run,var}
  '';

  preFixup = ''
    # Remove anything from systemd_lib
    pushd '${systemd_lib}' >/dev/null
    find . -not -type d -exec rm -v "$out"/{} \;
    popd >/dev/null
  '';

  passthru = {
    interfaceVersion = 4;
  };

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
