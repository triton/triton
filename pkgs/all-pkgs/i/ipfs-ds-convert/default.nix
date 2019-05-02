{ lib
, buildGoModule
, fetchGoModule
, fetchTritonPatch
}:

let
  inherit (builtins.fromJSON (builtins.readFile ./source.json))
    version;

  name = "ipfs-ds-convert-${version}";
in
buildGoModule {
  inherit name;

  src = fetchGoModule {
    inherit name;
    gomod = ./go.mod;
    gosum = ./go.sum;
    sourceJSON = ./source.json;
  };

  patches = [
    (fetchTritonPatch {
      rev = "6c3aef9b462db920e9ed47141d1eb94561e01080";
      file = "i/ipfs-ds-convert/fix.patch";
      sha256 = "e3b27dd7a0ce47b18836527de66b5c6821f6e5787c76b42ad3ce464d2929c2f8";
    })
  ];

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
