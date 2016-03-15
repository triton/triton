{ stdenv
, bison
, cmake
, fetchurl
, flex
, ninja
}:

stdenv.mkDerivation rec {
  name = "libcue-${version}";
  version = "2.0.1";

  src = fetchurl {
    url = "https://github.com/lipnitsk/libcue/archive/v${version}.tar.gz";
    sha256 = "0lg18cp06lgsni8dg971gzmnjavra0lqccihl09dl6nylsvyizb3";
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
