{ stdenv
, docbook_xml_dtd_42
, docbook-xsl
, fetchurl
, libxslt
, python3
, samba_full
, waf

, cmocka
, lmdb
, popt
, talloc
, tdb
, tevent
}:

let
  name = "ldb-1.5.3";

  tarballUrls = [
    "mirror://samba/ldb/${name}.tar"
  ];
in
stdenv.mkDerivation rec {
  inherit name;

  src = fetchurl {
    urls = map (n: "${n}.gz") tarballUrls;
    hashOutput = false;
    sha256 = "1a8acfa5bea27c4103151d169a1e47f0ce9e42e2a6e793e57d6df298aafabd00";
  };

  nativeBuildInputs = [
    docbook_xml_dtd_42
    docbook-xsl
    libxslt
    waf
  ];

  buildInputs = [
    cmocka
    lmdb
    talloc
    tdb
    tevent
    popt
  ];

  wafForBuild = "buildtools/bin/waf";
  wafVendored = true;

  wafFlags = [
    "--disable-python"
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
