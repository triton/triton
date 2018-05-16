{ stdenv
, cmake
, fetchurl
, ninja
}:

stdenv.mkDerivation rec {
  name = "libebml-1.3.6";

  src = fetchurl {
    url = "https://dl.matroska.org/downloads/libebml/${name}.tar.xz";
    multihash = "Qma3fGKxMKiPRqFzTM7Z1TPnmTur6KfEN4tf9q2NpHFLHE";
    sha256 = "1e5a7a7820c493aa62b0f35e15b4233c792cc03458c55ebdfa7a6521e4b43e9e";
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
