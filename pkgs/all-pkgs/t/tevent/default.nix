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
  version = "0.9.36";
  newVersion = "0.9.36";

  tarballUrls = version: [
    "mirror://samba/tevent/tevent-${version}.tar"
  ];
in
stdenv.mkDerivation rec {
  name = "tevent-${version}";

  src = fetchurl {
    urls = map (n: "${n}.gz") (tarballUrls version);
    hashOutput = false;
    sha256 = "bd2b6be3fd1601ed7f176e99111e322c57d58e425cc149ee80c7dd4fed263b4c";
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
      outputHash = "bd2b6be3fd1601ed7f176e99111e322c57d58e425cc149ee80c7dd4fed263b4c";
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
