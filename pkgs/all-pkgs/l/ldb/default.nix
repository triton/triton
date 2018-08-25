{ stdenv
, docbook_xml_dtd_42
, docbook-xsl
, fetchurl
, libxslt
, python
, samba_full

, cmocka
, lmdb
, popt
, talloc
, tdb
, tevent
}:

let
  name = "ldb-1.5.1";

  tarballUrls = [
    "mirror://samba/ldb/${name}.tar"
  ];
in
stdenv.mkDerivation rec {
  inherit name;

  src = fetchurl {
    urls = map (n: "${n}.gz") tarballUrls;
    hashOutput = false;
    sha256 = "232e54b87c53210a6861424ad411b04dbfa0f2ca4bc463aefea188158e0cc963";
  };

  nativeBuildInputs = [
    docbook_xml_dtd_42
    docbook-xsl
    libxslt
    python
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
