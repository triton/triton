{ stdenv
, fetchFromGitHub
, lib
}:

let
  date = "2018-03-30";
  rev = "54f55a2f02a823e5f5c87abe853bb76d1170718d";
in
stdenv.mkDerivation {
  name = "http-parser-${date}";

  src = fetchFromGitHub {
    version = 6;
    owner = "nodejs";
    repo = "http-parser";
    inherit rev;
    sha256 = "be29d861db71cbdb8e9723abee049945aa34b37104aa7237d192b363eb134e63";
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
