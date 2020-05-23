{ stdenv
, fetchFromGitHub
, lib
}:

let
  date = "2020-05-15";
  rev = "d9275da4650fd1133ddc96480df32a9efe4b059b";
in
stdenv.mkDerivation {
  name = "http-parser-${date}";

  src = fetchFromGitHub {
    version = 6;
    owner = "nodejs";
    repo = "http-parser";
    inherit rev;
    sha256 = "3127d5b23f14867dfa898173b168762ca30cd14628436fead1153154927bde3a";
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
