{ lib
, buildGo
, fetchFromGitHub
}:

let
  version = "2.6.0";
in
buildGo {
  name = "lego-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "go-acme";
    repo = "lego";
    rev = "v${version}";
    sha256 = "b2927bef2a00f24fd43bd85cd081a5ba7e2b551379e5efea4bf99f2daed83da5";
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
