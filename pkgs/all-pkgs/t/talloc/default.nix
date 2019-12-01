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
  version = "2.3.0";
  newVersion = "2.3.0";

  tarballUrls = version: [
    "mirror://samba/talloc/talloc-${version}.tar"
  ];
in
stdenv.mkDerivation rec {
  name = "talloc-${version}";

  src = fetchurl {
    urls = map (n: "${n}.gz") (tarballUrls version);
    hashOutput = false;
    sha256 = "75d5bcb34482545a82ffb06da8f6c797f963a0da450d0830c669267b14992fc6";
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
      outputHash = "75d5bcb34482545a82ffb06da8f6c797f963a0da450d0830c669267b14992fc6";
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
