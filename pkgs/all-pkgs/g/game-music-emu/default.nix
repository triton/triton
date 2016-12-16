{ stdenv
, cmake
, fetchurl
, ninja
}:

stdenv.mkDerivation rec {
  name = "game-music-emu-0.6.1";

  src = fetchurl {
    urls = [
      "https://bitbucket.org/mpyne/game-music-emu/downloads/${name}.tar.bz2"
      "mirror://gentoo/distfiles/${name}.tar.bz2"
    ];
    sha256 = "dc11bea098072d540d4d52dfb252e76fc3d3af67ee2807da48fbd8dbda3fd321";
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
