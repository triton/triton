{ stdenv
, fetchFromGitHub
, lib
}:

let
  date = "2018-02-09";
  rev = "dd74753cf5cf8944438d6f49ddf46f9659993dfb";
in
stdenv.mkDerivation {
  name = "http-parser-${date}";

  src = fetchFromGitHub {
    version = 5;
    owner = "nodejs";
    repo = "http-parser";
    inherit rev;
    sha256 = "91a55f9b7449d20d9357e9898b38b89a05ffd43ef5b71a188597eea77730b47e";
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
