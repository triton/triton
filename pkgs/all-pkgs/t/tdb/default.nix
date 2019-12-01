{ stdenv
, docbook_xml_dtd_42
, docbook-xsl
, fetchurl
, libxslt
, python3
, samba_full
, waf

, ncurses
, readline
}:

let
  name = "tdb-1.4.2";

  tarballUrls = [
    "mirror://samba/tdb/${name}.tar"
  ];
in
stdenv.mkDerivation rec {
  inherit name;

  src = fetchurl {
    urls = map (n: "${n}.gz") tarballUrls;
    hashOutput = false;
    sha256 = "9040b2cce4028e392f063f91bbe76b8b28fecc2b7c0c6071c67b5eb3168e004a";
  };

  nativeBuildInputs = [
    docbook_xml_dtd_42
    docbook-xsl
    libxslt
    waf
  ];

  buildInputs = [
    readline
    ncurses
  ];

  wafForBuild = "buildtools/bin/waf";
  wafVendored = true;

  wafConfigureFlags = [
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
