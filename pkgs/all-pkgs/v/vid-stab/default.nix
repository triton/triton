{ stdenv
, cmake
, fetchFromGitHub
, lib
, ninja
}:

let
  version = "1.1.0";
in
stdenv.mkDerivation rec {
  name = "vid-stab-${version}";

  src = fetchFromGitHub {
    version = 3;
    owner = "georgmartius";
    repo = "vid.stab";
    rev = "v${version}";
    sha256 = "4fc53aba090d7b4741a96e7345ac2a0d420a759d3e3d1f609c568a6d7d3e0c37";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  meta = with lib; {
    description = "Video stabilization library";
    homepage = http://public.hronopik.de/vid.stab/;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
