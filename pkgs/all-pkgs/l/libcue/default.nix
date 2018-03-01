{ stdenv
, bison
, cmake
, fetchFromGitHub
, flex
, lib
, ninja
}:

let
  version = "2.2.0";
in
stdenv.mkDerivation rec {
  name = "libcue-${version}";

  src = fetchFromGitHub {
    version = 5;
    owner = "lipnitsk";
    repo = "libcue";
    rev = "v${version}";
    sha256 = "d967e7e6087586f771281072ddc4e94afd56fcb7fcfe1b2e9931866d41df2b6b";
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
