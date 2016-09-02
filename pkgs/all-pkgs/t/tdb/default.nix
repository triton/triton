{ stdenv
, docbook_xml_dtd_42
, docbook-xsl
, fetchurl
, libxslt
, python
, samba_full

, ncurses
, readline
}:

let
  name = "tdb-1.3.10";

  tarballUrls = [
    "mirror://samba/tdb/${name}.tar"
  ];
in
stdenv.mkDerivation rec {
  inherit name;

  src = fetchurl {
    urls = map (n: "${n}.gz") tarballUrls;
    hashOutput = false;
    sha256 = "5578fb726bd04835f250bea11fe7d1398fe0bb3a7c9390404241c83cd6b50c1c";
  };

  nativeBuildInputs = [
    docbook_xml_dtd_42
    docbook-xsl
    libxslt
    python
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

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.asc") tarballUrls;
      pgpDecompress = true;
      inherit (samba_full.pgp.library) pgpKeyFingerprint;
      inherit (src) urls outputHash outputHashAlgo;
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
