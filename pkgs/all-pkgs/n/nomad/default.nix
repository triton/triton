{ lib
, buildGo
, fetchFromGitHub
}:

let
  version = "0.9.4";
in
buildGo {
  name = "nomad-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "hashicorp";
    repo = "nomad";
    rev = "v${version}";
    sha256 = "1dedb8452b055a9d565853abc8b7a73be2b728624c176c8c58064b9b5e5c3890";
  };

  srcRoot = null;

  postUnpack = ''
    srcNew="$NIX_BUILD_TOP"/go/src/github.com/hashicorp/nomad
    mkdir -p "$(dirname "$srcNew")"
    mv "$srcRoot" "$srcNew"
    srcRoot="$srcNew"
  '';

  goFlags = [
    "-tags" "nonvidia"
  ];

  installedSubmodules = [
    "."
  ];

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
