{ stdenv
, fetchFromGitHub
}:

let
  version = "2.7.1";
in
stdenv.mkDerivation {
  name = "http-parser-${version}";

  src = fetchFromGitHub {
    version = 1;
    owner = "nodejs";
    repo = "http-parser";
    rev = "v${version}";
    sha256 = "36a70a437524904f1520d578f4c95e1c606b1746611863979eecfc20d2602469";
  };

  postPatch = ''
    sed -i 's, -Werror,,g' Makefile
  '';

  preBuild = ''
    makeFlagsArray+=(
      "PREFIX=$out"
    )
  '';

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
