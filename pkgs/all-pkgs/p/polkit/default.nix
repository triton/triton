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
, spidermonkey_60
, gobject-introspection
, systemd_lib
}:

let
  version = "0.116";
in
stdenv.mkDerivation rec {
  name = "polkit-${version}";

  src = fetchurl {
    url = "https://www.freedesktop.org/software/polkit/releases/${name}.tar.gz";
    multihash = "Qmf262WJaCdgGQ2SBtAyaPLnDgBJ7duQo7XdV3kh12upmK";
    hashOutput = false;
    sha256 = "88170c9e711e8db305a12fdb8234fac5706c61969b94e084d0f117d8ec5d34b1";
  };

  nativeBuildInputs = [
    #docbook_xml_dtd_412
    #docbook-xsl
    #gettext
    intltool
    #libxslt
    perl
  ];

  buildInputs = [
    expat
    glib
    gobject-introspection
    pam
    spidermonkey_60
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
