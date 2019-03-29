{ stdenv
, docbook-xsl
, docbook_xml_dtd_42
, fetchurl
, lib
, libxslt
, python3
, samba_full
, waf
}:

let
  version = "2.2.0";
  newVersion = "2.2.0";

  tarballUrls = version: [
    "mirror://samba/talloc/talloc-${version}.tar"
  ];
in
stdenv.mkDerivation rec {
  name = "talloc-${version}";

  src = fetchurl {
    urls = map (n: "${n}.gz") (tarballUrls version);
    hashOutput = false;
    sha256 = "5c6f6a45ef96b3fd0b28942673a68d0c6af5dcca9d676a2e4d57ce7e86c22ebc";
  };

  nativeBuildInputs = [
    docbook-xsl
    docbook_xml_dtd_42
    libxslt
    waf
  ];

  wafForBuild = "buildtools/bin/waf";
  wafVendored = true;

  wafConfigureFlags = [
    "--disable-python"
    "--enable-talloc-compat1"
    "--bundled-libraries=NONE"
    "--builtin-libraries=replace"
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      urls = map (n: "${n}.gz") (tarballUrls newVersion);
      inherit (src) outputHashAlgo;
      outputHash = "5c6f6a45ef96b3fd0b28942673a68d0c6af5dcca9d676a2e4d57ce7e86c22ebc";
      fullOpts = {
        pgpsigUrls = map (n: "${n}.asc") (tarballUrls newVersion);
        pgpDecompress = true;
        inherit (samba_full.pgp.library) pgpKeyFingerprint;
      };
    };
  };

  meta = with lib; {
    description = "Hierarchical pool based memory allocator with destructors";
    homepage = http://tdb.samba.org/;
    license = licenses.gpl3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
