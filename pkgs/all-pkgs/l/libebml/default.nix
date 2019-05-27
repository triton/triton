{ stdenv
, cmake
, fetchurl
, ninja
}:

stdenv.mkDerivation rec {
  name = "libebml-1.3.8";

  src = fetchurl {
    url = "https://dl.matroska.org/downloads/libebml/${name}.tar.xz";
    multihash = "QmVENAkgir7WTUyeqkhH1LjXy5ks6pisQwxMxNA5gQmg6z";
    sha256 = "8b33246580249a9f33fac283ed474d68aada1433ff254808cab0571959555b78";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  cmakeFlags = [
    "-DBUILD_SHARED_LIBS=ON"
  ];

  meta = with stdenv.lib; {
    description = "Extensible Binary Meta Language library";
    license = licenses.lgpl21;
    homepage = http://dl.matroska.org/downloads/libebml/;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
