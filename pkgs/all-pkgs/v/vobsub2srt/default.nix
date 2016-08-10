{ stdenv
, cmake
, fetchFromGitHub
, ninja

, libtiff
, tesseract
}:

stdenv.mkDerivation rec {
  name = "vobsub2srt-${version}";
  version = "2016-05-21";

  src = fetchFromGitHub {
    owner = "ruediger";
    repo = "VobSub2SRT";
    rev = "04bd6c98a1b326a77ba2abd5b4f1c003535a4a28";
    sha256 = "9a08108255b6a583bd7a0592545fa9d4b2f313ec128adae9240acce85ffef8c4";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    libtiff
    tesseract
  ];

  prePatch = /* Prevent build from using autoconf */ ''
    rm -fv ./configure
  '';

  cmakeFlags = [
    "-DBUILD_STATIC=OFF"
  ];

  meta = with stdenv.lib; {
    description = "Converts VobSub subtitles into SRT subtitles";
    homepage = https://github.com/ruediger/VobSub2SRT;
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
