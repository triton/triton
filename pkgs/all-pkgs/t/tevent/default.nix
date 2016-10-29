{ stdenv
, docbook-xsl
, docbook_xml_dtd_42
, fetchurl
, libxslt
, python2
, samba_full

, ncurses
, readline
, talloc
}:

let
  version = "0.9.31";
  newVersion = "0.9.31";

  tarballUrls = version: [
    "mirror://samba/tevent/tevent-${version}.tar"
  ];
in
stdenv.mkDerivation rec {
  name = "tevent-${version}";

  src = fetchurl {
    urls = map (n: "${n}.gz") (tarballUrls version);
    hashOutput = false;
    sha256 = "4a13f2256ad804c860e84068258bd0f8be31cf0c79aa8f3019fa32f6928c2bfc";
  };

  nativeBuildInputs = [
    docbook-xsl
    docbook_xml_dtd_42
    libxslt
    python2
  ];

  buildInputs = [
    ncurses
    readline
    talloc
  ];

  preConfigure = ''
    patchShebangs buildtools/bin/waf
  '';

  configureFlags = [
    "--bundled-libraries=NONE"
    "--builtin-libraries=replace"
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      urls = map (n: "${n}.gz") (tarballUrls newVersion);
      pgpsigUrls = map (n: "${n}.asc") (tarballUrls newVersion);
      pgpDecompress = true;
      inherit (samba_full.pgp.library) pgpKeyFingerprint;
      inherit (src) outputHashAlgo;
      outputHash = "4a13f2256ad804c860e84068258bd0f8be31cf0c79aa8f3019fa32f6928c2bfc";
    };
  };

  meta = with stdenv.lib; {
    description = "An event system based on the talloc memory management library";
    homepage = http://tevent.samba.org/;
    license = licenses.lgpl3Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
