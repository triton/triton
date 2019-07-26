{ lib
, buildGo
, fetchFromGitHub
}:

let
  version = "1.1.4";
in
buildGo {
  name = "vault-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "hashicorp";
    repo = "vault";
    rev = "v${version}";
    sha256 = "4179e0665b5814f495026d36503f383357b3cf58618aecffbd49b95d46c5862f";
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
