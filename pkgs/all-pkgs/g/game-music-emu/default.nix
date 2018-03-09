{ stdenv
, cmake
, fetchurl
, ninja
}:

stdenv.mkDerivation rec {
  name = "game-music-emu-0.6.2";

  src = fetchurl {
    urls = [
      "https://bitbucket.org/mpyne/game-music-emu/downloads/${name}.tar.xz"
      "mirror://gentoo/distfiles/${name}.tar.xz"
    ];
    sha256 = "5046cb471d422dbe948b5f5dd4e5552aaef52a0899c4b2688e5a68a556af7342";
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

  passthru = {
    srcVerification = fetchurl rec {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      pgpsigUrls = map (n: "${n}.asc") urls;
      # Michael Pyne
      pgpKeyFingerprint = "5406 ECE8 3665 DA9D 201D  3572 0BAF 0C9C 7B6A E9F2";
      failEarly = true;
    };
  };

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
