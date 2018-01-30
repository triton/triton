{ stdenv
, autoreconfHook
, fetchFromGitHub
, lib
}:

let
  version = "2018-01-28";
in
stdenv.mkDerivation rec {
  name = "fribidi-${version}";

  src = fetchFromGitHub {
    version = 5;
    owner = "fribidi";
    repo = "fribidi";
    rev = "d18badec88bca8f6f4149156ebe7f1c6467a7bd8";
    sha256 = "b61899c1bb39ad2270b23d81d3d18af8a164ff6635aa4f034cda4316e2ef296e";
  };

  nativeBuildInputs = [
    autoreconfHook
  ];

  buildParallel = false;

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
