{ lib
, buildGo
, fetchFromGitHub
, zip
}:

let
  version = "4.0.2";
in
buildGo {
  name = "teleport-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "gravitational";
    repo = "teleport";
    rev = "v${version}";
    sha256 = "95a8757d88d9067c5379c85eca4e34acf3d5305715d2e42ddf49f5a2b81efb1d";
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
