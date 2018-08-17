{ stdenv
, fetchFromGitHub
, lib
}:

let
  date = "2018-07-18";
  rev = "77310eeb839c4251c07184a5db8885a572a08352";
in
stdenv.mkDerivation {
  name = "http-parser-${date}";

  src = fetchFromGitHub {
    version = 6;
    owner = "nodejs";
    repo = "http-parser";
    inherit rev;
    sha256 = "6bb20c129802f57d0675f67e5205221d504138786c22833afcf34025daf6a6bf";
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
