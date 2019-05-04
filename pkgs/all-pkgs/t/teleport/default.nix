{ lib
, buildGoModule
, fetchFromGitHub
, zip
}:

let
  version = "3.2.5";
in
buildGoModule {
  name = "teleport-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "gravitational";
    repo = "teleport";
    rev = "v${version}";
    sha256 = "89cb20a057b34e288dcd0ebfea127064f7cf86e83910c2cb589d103c5a37a0b8";
  };

  srcRoot = null;

  nativeBuildInputs = [
    zip
  ];

  postUnpack = ''
    srcNew="$NIX_BUILD_TOP"/go/src/github.com/gravitational/teleport
    mkdir -p "$(dirname "$srcNew")"
    mv "$srcRoot" "$srcNew"
    srcRoot="$srcNew"
  '';

  installedSubmodules = [
    "tool/..."
  ];
  
  postFixup = ''
    pushd web/dist >/dev/null
    zip -r "$NIX_BUILD_TOP"/assets.zip .
    popd >/dev/null
    cat "$NIX_BUILD_TOP"/assets.zip >>"$out"/bin/teleport
    zip -A "$out"/bin/teleport
  '';

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
