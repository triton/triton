{ stdenv
, docbook_xsl
, docbook_xml_dtd_42
, fetchurl
, libxslt
, python2
, samba_full
}:

let
  version = "2.1.7";
  newVersion = "2.1.7";

  tarballUrls = version: [
    "mirror://samba/talloc/talloc-${version}.tar"
  ];
in
stdenv.mkDerivation rec {
  name = "talloc-${version}";

  src = fetchurl {
    urls = map (n: "${n}.gz") (tarballUrls version);
    allowHashOutput = false;
    sha256 = "19154e728e48d29c7398f470b0a59d093edc836156b41ffe20d247d6ec9fa006";
  };

  nativeBuildInputs = [
    docbook_xsl
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
    srcVerified = fetchurl {
      failEarly = true;
      urls = map (n: "${n}.gz") (tarballUrls newVersion);
      pgpsigUrls = map (n: "${n}.asc") (tarballUrls newVersion);
      pgpDecompress = true;
      inherit (samba_full.pgp.library) pgpKeyFingerprint;
      inherit (src) outputHashAlgo;
      outputHash = "19154e728e48d29c7398f470b0a59d093edc836156b41ffe20d247d6ec9fa006";
    };
  };

  meta = with stdenv.lib; {
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
