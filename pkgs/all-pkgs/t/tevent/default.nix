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
  version = "0.10.0";
  newVersion = "0.10.0";

  tarballUrls = version: [
    "mirror://samba/tevent/tevent-${version}.tar"
  ];
in
stdenv.mkDerivation rec {
  name = "tevent-${version}";

  src = fetchurl {
    urls = map (n: "${n}.gz") (tarballUrls version);
    hashOutput = false;
    sha256 = "33f39612cd6d1ae6a737245784581494846f5bb07827983d2f41f942446aa4e6";
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
      outputHash = "33f39612cd6d1ae6a737245784581494846f5bb07827983d2f41f942446aa4e6";
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
