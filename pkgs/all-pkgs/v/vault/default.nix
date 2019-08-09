{ lib
, buildGo
, fetchFromGitHub
}:

let
  version = "1.2.1";
in
buildGo {
  name = "vault-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "hashicorp";
    repo = "vault";
    rev = "v${version}";
    sha256 = "7d17dbc676f1778ec1bf966d65edb23defd5c93cb7d63c8fb9f6d660d230bac6";
  };

  srcRoot = null;

  postUnpack = ''
    srcNew="$NIX_BUILD_TOP"/go/src/github.com/hashicorp/vault
    mkdir -p "$(dirname "$srcNew")"
    mv "$srcRoot" "$srcNew"
    srcRoot="$srcNew"
  '';

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
