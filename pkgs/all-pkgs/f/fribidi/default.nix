{ stdenv
, autoreconfHook
, fetchFromGitHub
, lib
}:

let
  version = "2017-12-05";
in
stdenv.mkDerivation rec {
  name = "fribidi-${version}";

  src = fetchFromGitHub {
    version = 3;
    owner = "fribidi";
    repo = "fribidi";
    rev = "0efbaa9052320a951823a6e776b30a580e3a2b4e";
    sha256 = "44d67067d76179546e5af2bf8d73beafcd2f5068ddfc84cb3427fb25be7b3c51";
  };

  nativeBuildInputs = [
    autoreconfHook
  ];

  parallelBuild = false;

  meta = with lib; {
    description = "GNU implementation of the Unicode Bidirectional Algorithm";
    homepage = https://github.com/fribidi/fribidi;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
