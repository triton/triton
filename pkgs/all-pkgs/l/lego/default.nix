{ lib
, buildGo
, fetchFromGitHub
}:

let
  version = "2.5.0";
in
buildGo {
  name = "lego-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "go-acme";
    repo = "lego";
    rev = "v${version}";
    sha256 = "00f5120fb2b08a5ec12a6fa9b59d16cf6373dec4e081d14e7a32fff57922cc88";
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
