{ stdenv
, docbook_xml_dtd_42
, docbook-xsl
, fetchurl
, libxslt
, python3
, samba_full

, cmocka
, lmdb
, popt
, talloc
, tdb
, tevent
}:

let
  name = "ldb-1.5.2";

  tarballUrls = [
    "mirror://samba/ldb/${name}.tar"
  ];
in
stdenv.mkDerivation rec {
  inherit name;

  src = fetchurl {
    urls = map (n: "${n}.gz") tarballUrls;
    hashOutput = false;
    sha256 = "61afb5050a04e0361ee5869658b4e935dbe2a7d1c58018c720e0e68163520e9e";
  };

  nativeBuildInputs = [
    docbook_xml_dtd_42
    docbook-xsl
    libxslt
    python3
  ];

  buildInputs = [
    cmocka
    lmdb
    talloc
    tdb
    tevent
    popt
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
        inherit (samba_full.pgp.library)
          pgpKeyFingerprint;
      };
    };
  };

  meta = with stdenv.lib; {
    description = "An LDAP-like embedded database";
    homepage = http://ldb.samba.org/;
    license = licenses.lgpl3Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
