{ stdenv
, cmake
, fetchurl
, ninja
}:

stdenv.mkDerivation rec {
  name = "game-music-emu-0.6.0";

  src = fetchurl {
    url = "https://bitbucket.org/mpyne/game-music-emu/downloads/"
        + "${name}.tar.bz2";
    sha256 = "11s9l938nxbrk7qb2k1ppfgizcz00cakbxgv0gajc6hyqv882vjh";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  cmakeFlags = [
    "-DBUILD_SHARED_LIBS=ON"
    "-DUSE_GME_AY=ON"
    "-DUSE_GME_GBS=ON"
    "-DUSE_GME_GYM=ON"
    "-DUSE_GME_HES=ON"
    "-DUSE_GME_KSS=ON"
    "-DUSE_GME_NSF=ON"
    "-DUSE_GME_NSFE=ON"
    "-DUSE_GME_SAP=ON"
    "-DUSE_GME_SPC=ON"
    "-DUSE_GME_VGM=ON"
  ];

  meta = with stdenv.lib; {
    description = "A collection of video game music file emulators";
    homepage = https://bitbucket.org/mpyne/game-music-emu/;
    license = licenses.lgpl21Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
