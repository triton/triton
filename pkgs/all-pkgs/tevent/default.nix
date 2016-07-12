{ stdenv
, docbook_xsl
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
  version = "0.9.28";
  newVersion = "0.9.28";

  tarballUrls = version: [
    "mirror://samba/tevent/tevent-${version}.tar"
  ];
in
stdenv.mkDerivation rec {
  name = "tevent-${version}";

  src = fetchurl {
    urls = map (n: "${n}.gz") (tarballUrls version);
    allowHashOutput = false;
    sha256 = "0a9ml52jjnzz7qg9z750mavlvs1yibjwrzy4yl55dc95j0vm7n84";
  };

  nativeBuildInputs = [
    docbook_xsl
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
      outputHash = "0a9ml52jjnzz7qg9z750mavlvs1yibjwrzy4yl55dc95j0vm7n84";
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
