{ stdenv
, bison
, cmake
, fetchFromGitHub
, flex
, lib
, ninja
}:

let
  version = "2.2.1";
in
stdenv.mkDerivation rec {
  name = "libcue-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "lipnitsk";
    repo = "libcue";
    rev = "v${version}";
    sha256 = "eb3ee520325181ee2e0308aefb0dc7cdedfea2cecf1574f73ac0e5f6b53a0aa4";
  };

  nativeBuildInputs = [
    bison
    cmake
    flex
    ninja
  ];

  meta = with lib; {
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
