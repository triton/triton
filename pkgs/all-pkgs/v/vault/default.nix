{ lib
, buildGoModule
, fetchFromGitHub
}:

let
  version = "1.1.2";
in
buildGoModule {
  name = "vault-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "hashicorp";
    repo = "vault";
    rev = "v${version}";
    sha256 = "9349b55ea4996f41bd03b4abbf8471371e60f3be7f6a37a21d65b2c9df16d135";
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
