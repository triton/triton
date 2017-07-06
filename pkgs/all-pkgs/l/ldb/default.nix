{ stdenv
, docbook_xml_dtd_42
, docbook-xsl
, fetchurl
, libxslt
, python
, samba_full

, cmocka
, popt
, talloc
, tdb
, tevent
}:

let
  name = "ldb-1.2.0";

  tarballUrls = [
    "mirror://samba/ldb/${name}.tar"
  ];
in
stdenv.mkDerivation rec {
  inherit name;

  src = fetchurl {
    urls = map (n: "${n}.gz") tarballUrls;
    hashOutput = false;
    sha256 = "cf5d8cea4d6eb549a8a9bf4ca22f71abf3ee1bcdb4d3dfb9b7d81a78a6b274e5";
  };

  nativeBuildInputs = [
    docbook_xml_dtd_42
    docbook-xsl
    libxslt
    python
  ];

  buildInputs = [
    cmocka
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
      pgpsigUrls = map (n: "${n}.asc") tarballUrls;
      pgpDecompress = true;
      inherit (samba_full.pgp.library) pgpKeyFingerprint;
      inherit (src) urls outputHash outputHashAlgo;
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
