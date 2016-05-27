{ callPackage
, lib
, newScope

, self
, channel
}:

let
  callPackage' = callPackage;
in
let
  buildRustPackage = callPackage ../all-pkgs/b/build-rust-package { };

  fetchCargo = callPackage ../all-pkgs/f/fetch-cargo { };

  cargo_bootstrap = callPackage ../all-pkgs/c/cargo/bootstrap.nix {
    rustc = rustc_bootstrap;
  };

  rustc_bootstrap = callPackage ../all-pkgs/r/rustc/bootstrap.nix { };

  callPackage = newScope (self // {
    rustPackages = self;
    inherit
      buildRustPackage
      fetchCargo;
  });
in
{
  cargo = callPackage ../all-pkgs/c/cargo {
    inherit cargo_bootstrap;
    buildRustPackage = buildRustPackage.override {
      cargo = cargo_bootstrap;
    };
    fetchCargo = fetchCargo.override {
      cargo = cargo_bootstrap;
    };
  };

  # These packages are special in that they use the top-level callPackage since they aren't cargo packages
  rustc = callPackage' ../all-pkgs/r/rustc {
    cargo = cargo_bootstrap;
    rustc = rustc_bootstrap;
    inherit
      channel;
  };
}
