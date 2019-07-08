{ lib
, buildGo
, fetchFromGitHub
}:

let
  version = "1.1.3";
in
buildGo {
  name = "vault-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "hashicorp";
    repo = "vault";
    rev = "v${version}";
    sha256 = "266ca829bdf67c4617e4bd173c9873bf49a4d57da0153761b6ed36c038ca0f6b";
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
