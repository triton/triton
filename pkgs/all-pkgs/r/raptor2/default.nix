{ stdenv
, bison
, fetchurl
, flex

, curl
, icu
, libxml2
, libxslt
, yajl
}:

stdenv.mkDerivation rec {
  name = "raptor2-2.0.15";

  src = fetchurl {
    url = "http://download.librdf.org/source/${name}.tar.gz";
    sha256 = "ada7f0ba54787b33485d090d3d2680533520cd4426d2f7fb4782dd4a6a1480ed";
  };

  nativeBuildInputs = [
    bison
    flex
  ];

  buildInputs = [
    curl
    icu
    libxml2
    libxslt
    yajl
  ];

  configureFlags = [
    "--enable-release"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--without-memory-signing"
  ];

  postInstall = "rm -rvf $out/share/gtk-doc";

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      failEarly = true;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      pgpKeyFingerprint = "F879 F0DE DA78 0198 DD08  DC64 43EC 9250 4F71 955A";
    };
  };

  meta = with stdenv.lib; {
    description = "The RDF Parser Toolkit";
    homepage = "http://librdf.org/raptor";
    license = with licenses; [
      asl20
      gpl2
      lgpl21
    ];
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
