{ lib
, buildGoModule
, fetchGoModule
}:

let
  inherit (builtins.fromJSON (builtins.readFile ./source.json))
    version;

  name = "ipfs-${version}";
in
buildGoModule {
  inherit name;

  src = fetchGoModule {
    inherit name;
    gomod = ./go.mod;
    gosum = ./go.sum;
    sourceJSON = ./source.json;
  };

  installedSubmodules = [
    "cmd/ipfs"
  ];

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
