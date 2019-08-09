{ lib
, buildGo
, fetchFromGitHub
, zip
}:

let
  version = "4.0.4";
in
buildGo {
  name = "teleport-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "gravitational";
    repo = "teleport";
    rev = "v${version}";
    sha256 = "80ebc9b5d8e84774a9636bcc17de7706f5c1ec1b97d97acc0739169c4037d360";
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
