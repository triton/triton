{ stdenv
, cmake
, fetchurl
, lib
, ninja

, libebml
}:

stdenv.mkDerivation rec {
  name = "libmatroska-1.5.1";

  src = fetchurl {
    url = "https://dl.matroska.org/downloads/libmatroska/${name}.tar.xz";
    multihash = "QmP8db6s85wdAdZJbRw6ogxxs1K3cCXqaqAQBjzuwRLwJd";
    sha256 = "bb8dd99e49e156bff29fac15b81aad65e99c7641b502426adb50cdee8a21dbfb";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    libebml
  ];

  cmakeFlags = [
    "-DBUILD_SHARED_LIBS=ON"
  ];

  meta = with lib; {
    description = "A library to parse Matroska files";
    homepage = http://matroska.org/;
    license = licenses.lgpl21;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
