{ targetSystem ? builtins.currentSystem
, hostSystem ? builtins.currentSystem
, config ? null
} @ args:

let
  # Minimum required version for evaluating Nixpkgs
  requiredVersion = "1.10";
in
if ! builtins ? nixVersion || builtins.compareVersions requiredVersion builtins.nixVersion == 1 then
  abort "This version of Triton requires Nix >= ${requiredVersion}, please upgrade!"
else
  import ./pkgs/top-level/all-packages.nix {
    inherit targetSystem hostSystem config;
    stdenv = null;
  }
