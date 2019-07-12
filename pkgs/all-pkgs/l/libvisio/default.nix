{ stdenv
, boost
, fetchurl
, gperf
, lib
, perl

, icu
, librevenge
, libxml2
}:

stdenv.mkDerivation rec {
  name = "libvisio-0.1.6";

  src = fetchurl {
    url = "https://dev-www.libreoffice.org/src/${name}.tar.xz";
    sha256 = "fe1002d3671d53c09bc65e47ec948ec7b67e6fb112ed1cd10966e211a8bb50f9";
  };

  nativeBuildInputs = [
    boost
    gperf
    perl
  ];

  buildInputs = [
    icu
    librevenge
    libxml2
  ];

  configureFlags = [
    "--disable-tests"
  ];

  NIX_CFLAGS_COMPILE = [
    "-std=c++14"
  ];

  meta = with lib; {
    description = "Library for parsing visio documents";
    homepage = https://wiki.documentfoundation.org/DLP/Libraries/libvisio;
    license = licenses.gpl2;
    maintainers = with maintianers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
