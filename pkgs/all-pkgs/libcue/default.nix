{ stdenv
, bison
, cmake
, fetchurl
, flex
, ninja
}:

stdenv.mkDerivation rec {
  name = "libcue-${version}";
  version = "2.1.0";

  src = fetchurl {
    url = "https://github.com/lipnitsk/libcue/archive/v${version}.tar.gz";
    sha256 = "288ddd01e5f9e8f901d0c205d31507e4bdffd2540fa86073f2fe82de066d2abb";
  };

  nativeBuildInputs = [
    bison
    cmake
    flex
    ninja
  ];

  meta = with stdenv.lib; {
    description = "A library for parsing cue sheets";
    homepage = http://sourceforge.net/projects/libcue/;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
