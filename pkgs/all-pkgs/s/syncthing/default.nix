{ lib
, buildGoModule
, fetchGoModule
}:

let
  inherit (builtins.fromJSON (builtins.readFile ./source.json))
    version;

  name = "syncthing-${version}";
in
buildGoModule {
  inherit name;

  src = fetchGoModule {
    inherit name;
    gomod = ./go.mod;
    gosum = ./go.sum;
    sourceJSON = ./source.json;
  };

  preBuild = ''
    for path in $(find . -name auto -type d); do
      pushd "$path" >/dev/null
      go generate .
      popd >/dev/null
    done
  '';

  installedSubmodules = [
    "cmd/..."
  ];

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
