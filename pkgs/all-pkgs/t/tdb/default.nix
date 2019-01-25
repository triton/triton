{ stdenv
, docbook_xml_dtd_42
, docbook-xsl
, fetchurl
, libxslt
, python3
, samba_full

, ncurses
, readline
}:

let
  name = "tdb-1.3.17";

  tarballUrls = [
    "mirror://samba/tdb/${name}.tar"
  ];
in
stdenv.mkDerivation rec {
  inherit name;

  src = fetchurl {
    urls = map (n: "${n}.gz") tarballUrls;
    hashOutput = false;
    sha256 = "1cb4399394c60a773430ca54848359adcf54fb6f136afdcfcbbe62b5f4245614";
  };

  nativeBuildInputs = [
    docbook_xml_dtd_42
    docbook-xsl
    libxslt
    python3
  ];

  buildInputs = [
    readline
    ncurses
  ];

  postPatch = ''
    patchShebangs buildtools/bin/waf
  '';

  configureFlags = [
    "--bundled-libraries=NONE"
    "--builtin-libraries=replace"
  ];

  buildPhase = ''
    buildtools/bin/waf build -j $NIX_BUILD_CORES
  '';

  installPhase = ''
    buildtools/bin/waf install -j $NIX_BUILD_CORES
  '';

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
      fullOpts = {
        pgpsigUrls = map (n: "${n}.asc") tarballUrls;
        pgpDecompress = true;
        inherit (samba_full.pgp.library) pgpKeyFingerprint;
      };
    };
  };

  meta = with stdenv.lib; {
    description = "The trivial database";
    homepage = http://tdb.samba.org/;
    license = licenses.lgpl3Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
