{ lib
, newScope
, pkgs

, channel
}:

let
  cargo_bootstrap = callPackage ../all-pkgs/c/cargo/bootstrap.nix {
    rustc = rustc_bootstrap;
  };

  rustc_bootstrap = callPackage ../all-pkgs/r/rustc/bootstrap.nix {
    rustc = self.rustc';
  };

  rust-std_bootstrap = callPackage ../all-pkgs/r/rust-std/bootstrap.nix {
    rustc = rustc_bootstrap;
  };

  callPackage = newScope (self // {
    inherit pkgs;
    rustPackages = self;
  });

  self = {

  buildCargo = callPackage ../all-pkgs/c/cargo/build.nix { };

  fetchCargo = callPackage ../all-pkgs/c/cargo/fetch.nix { };

  fetchCargoDeps = callPackage ../all-pkgs/c/cargo/fetch-deps.nix { };

  cargo' = callPackage ../all-pkgs/c/cargo {
    buildCargo = self.buildCargo.override {
      cargo = cargo_bootstrap;
    };
    fetchCargo = self.fetchCargo.override {
      cargo = cargo_bootstrap;
    };
  };
  # Temporary until we can rebuild it
  cargo = cargo_bootstrap;

  # These packages are special in that they use the top-level callPackage since they aren't cargo packages
  rustc' = callPackage ../all-pkgs/r/rustc {
    cargo = cargo_bootstrap;
    rustc = rustc_bootstrap;
    inherit
      channel;
  };
  # Temporary until we can rebuild it
  rustc = rustc_bootstrap;
  rust-std = rust-std_bootstrap;

  }; in self
