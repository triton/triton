{ lib
, buildGoModule
, fetchGoModule
}:

let
  inherit (builtins.fromJSON (builtins.readFile ./source.json))
    version;

  name = "minio-${version}";
in
buildGoModule {
  inherit name;

  src = fetchGoModule {
    inherit name;
    gomod = ./go.mod;
    gosum = ./go.sum;
    sourceJSON = ./source.json;
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
