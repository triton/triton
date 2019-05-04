{ lib
, buildGoModule
, fetchFromGitHub
}:

let
  version = "0.20.0";
in
buildGoModule {
  name = "consul-template-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "hashicorp";
    repo = "consul-template";
    rev = "v${version}";
    sha256 = "de30089a304b0981224bcae75b542b5a03384a54c4c679cbefafb53a6f06f5ac";
  };

  srcRoot = null;

  postUnpack = ''
    srcNew="$NIX_BUILD_TOP"/go/src/github.com/hashicorp/consul-template
    mkdir -p "$(dirname "$srcNew")"
    mv "$srcRoot" "$srcNew"
    srcRoot="$srcNew"
  '';

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
