{ lib
, buildGoModule
, fetchFromGitHub
, fetchTritonPatch
}:

let
  version = "0.9.1";
in
buildGoModule {
  name = "nomad-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "hashicorp";
    repo = "nomad";
    rev = "v${version}";
    sha256 = "7eb28d09b28ffe63ef64dacd948f403322f272e0ba8f8da0e43039c7aeb5aa6e";
  };

  patches = [
    (fetchTritonPatch {
      rev = "a215f1eccb99b10440c4aa6bd2195093cedc43cb";
      file = "n/nomad/0001-Allow-compiling-without-nvidia-integration.patch";
      sha256 = "75998540a7c17869987b549d7c8c2f974d7229d978484996f340d206cd6fa5e7";
    })
  ];

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
