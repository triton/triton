{ stdenv
, docbook-xsl
, docbook_xml_dtd_42
, fetchurl
, lib
, libxslt
, python2
, samba_full
}:

let
  version = "2.1.13";
  newVersion = "2.1.13";

  tarballUrls = version: [
    "mirror://samba/talloc/talloc-${version}.tar"
  ];
in
stdenv.mkDerivation rec {
  name = "talloc-${version}";

  src = fetchurl {
    urls = map (n: "${n}.gz") (tarballUrls version);
    hashOutput = false;
    sha256 = "84f399dbf0ad97006a2b4953ea99452d033faac15aabfddd4ba61734764c6047";
  };

  nativeBuildInputs = [
    docbook-xsl
    docbook_xml_dtd_42
    libxslt
    python2
  ];

  preConfigure = ''
    patchShebangs buildtools/bin/waf
  '';

  configureFlags = [
    "--enable-talloc-compat1"
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
      outputHash = "84f399dbf0ad97006a2b4953ea99452d033faac15aabfddd4ba61734764c6047";
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
