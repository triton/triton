{ stdenv
, docbook_xml_dtd_412
, docbook-xsl
, fetchurl
, gettext
, intltool
, lib
, libxslt
, perl

, glib
, expat
, pam
, spidermonkey_52
, gobject-introspection
, systemd_lib
}:

let
  version = "0.115";
in
stdenv.mkDerivation rec {
  name = "polkit-${version}";

  src = fetchurl {
    url = "https://www.freedesktop.org/software/polkit/releases/${name}.tar.gz";
    multihash = "QmUQ3hjxbm3pQnc2L1iPEW3NJuXnNrwuenfKv69jJRVMzi";
    hashOutput = false;
    sha256 = "2f87ecdabfbd415c6306673ceadc59846f059b18ef2fce42bac63fe283f12131";
  };

  nativeBuildInputs = [
    docbook_xml_dtd_412
    docbook-xsl
    gettext
    intltool
    libxslt
    perl
  ];

  buildInputs = [
    expat
    glib
    gobject-introspection
    pam
    spidermonkey_52
    systemd_lib
  ];

  postPatch = ''
    patchShebangs src/polkitbackend/toarray.pl

    # polkit-agent-helper-1 is a setuid binary so remap the path in the codebase.
    grep -q 'PACKAGE_PREFIX "/lib/polkit-1/polkit-agent-helper-1"' \
      src/polkitagent/polkitagentsession.c
    sed -i 's,PACKAGE_PREFIX "/lib/polkit-1,"/var/setuid-wrappers,g' \
      src/polkitagent/polkitagentsession.c
  '';

  preConfigure = ''
    configureFlagsArray+=(
      "--with-systemdsystemunitdir=$out/etc/systemd/system"
    )
  '';

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--datarootdir=/run/current-system/sw/share"
    "--enable-man-pages"
    "--disable-test"
    "--disable-examples"
    "--enable-libsystemd-login"
    "--enable-introspection"
    "--with-authfw=pam"
    "--with-os-type=triton" # not recognized but prevents impurities
  ];

  preInstall = ''
    installFlagsArray+=(
      "sysconfdir=$out/etc"
      "datarootdir=$out/share"
      "INTROSPECTION_GIRDIR=$out/share/gir-1.0"
      "INTROSPECTION_TYPELIBDIR=$out/lib/girepository-1.0"
    )
  '';

  installParallel = false;

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.sign") src.urls;
      pgpKeyFingerprints = [
        "C197 6D9E D91A 7459 CBCE  5314 5A33 F660 B384 79DF"
      ];
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with lib; {
    homepage = http://www.freedesktop.org/wiki/Software/polkit;
    description = "A toolkit for defining and handling the policy that allows unprivileged processes to speak to privileged processes";
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
