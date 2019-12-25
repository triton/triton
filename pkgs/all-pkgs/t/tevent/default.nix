{ stdenv
, docbook-xsl
, docbook_xml_dtd_42
, fetchurl
, libxslt
, samba_full
, waf

, ncurses
, readline
, talloc
}:

let
  version = "0.10.2";
  newVersion = "0.10.2";

  tarballUrls = version: [
    "mirror://samba/tevent/tevent-${version}.tar"
  ];
in
stdenv.mkDerivation rec {
  name = "tevent-${version}";

  src = fetchurl {
    urls = map (n: "${n}.gz") (tarballUrls version);
    hashOutput = false;
    sha256 = "f8427822e5b2878fb8b28d6f50d96848734f3f3130612fb574fdd2d2148a6696";
  };

  nativeBuildInputs = [
    docbook-xsl
    docbook_xml_dtd_42
    libxslt
    waf
  ];

  buildInputs = [
    ncurses
    readline
    talloc
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
      urls = map (n: "${n}.gz") (tarballUrls newVersion);
      inherit (src) outputHashAlgo;
      outputHash = "f8427822e5b2878fb8b28d6f50d96848734f3f3130612fb574fdd2d2148a6696";
      fullOpts = {
        pgpsigUrls = map (n: "${n}.asc") (tarballUrls newVersion);
        pgpDecompress = true;
        inherit (samba_full.pgp.library) pgpKeyFingerprint;
      };
    };
  };

  meta = with stdenv.lib; {
    description = "An event system based on the talloc memory management library";
    homepage = http://tevent.samba.org/;
    license = licenses.lgpl3Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
