{ allPackages ? (import ../../top-level/all-packages.nix)
, lib ? (import ../../../lib)
, targetSystem ? builtins.currentSystem
, hostSystem ? builtins.currentSystem
, config ? { }
}:

import ./default.nix {
  inherit allPackages lib targetSystem hostSystem config;
}
