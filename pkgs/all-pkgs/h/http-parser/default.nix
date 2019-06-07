{ stdenv
, fetchFromGitHub
, lib
}:

let
  date = "2019-04-15";
  rev = "5c17dad400e45c5a442a63f250fff2638d144682";
in
stdenv.mkDerivation {
  name = "http-parser-${date}";

  src = fetchFromGitHub {
    version = 6;
    owner = "nodejs";
    repo = "http-parser";
    inherit rev;
    sha256 = "04a767130568b436062740813c56f1a9eead7b4317916e68d4c3790e67dcb9bb";
  };

  preBuild = ''
    makeFlagsArray+=(
      "PREFIX=$out"
    )
  '';

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
