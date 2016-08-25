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
  version = "0.9.30";
  newVersion = "0.9.30";

  tarballUrls = version: [
    "mirror://samba/tevent/tevent-${version}.tar"
  ];
in
stdenv.mkDerivation rec {
  name = "tevent-${version}";

  src = fetchurl {
    urls = map (n: "${n}.gz") (tarballUrls version);
    allowHashOutput = false;
    sha256 = "5785915e6f76a8a7f7251055be1cef7a7465150a2f63d893082a1ab762c48cbd";
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
      outputHash = "5785915e6f76a8a7f7251055be1cef7a7465150a2f63d893082a1ab762c48cbd";
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
