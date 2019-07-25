{ lib
, buildGo
, fetchFromGitHub
}:

let
  version = "2.7.1";
in
buildGo {
  name = "lego-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "go-acme";
    repo = "lego";
    rev = "v${version}";
    sha256 = "707d0e07bbb92fce2e1386b3582e8226b2bbb1ae2cf55ef077e15697585cbb91";
  };

  srcRoot = null;

  postUnpack = ''
    srcNew="$NIX_BUILD_TOP"/go/src/github.com/go-acme/lego
    mkdir -p "$(dirname "$srcNew")"
    mv "$srcRoot" "$srcNew"
    srcRoot="$srcNew"
  '';
  
  installedSubmodules = [
    "cmd/lego"
  ];

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
