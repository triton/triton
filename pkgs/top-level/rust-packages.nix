{ lib
, newScope
, pkgs

, channel
}:

let
  cargo_bootstrap = callPackage ../all-pkgs/c/cargo/bootstrap.nix { };

  cargo_bootstrap_patched = callPackage ../all-pkgs/c/cargo {
    buildCargo = self.buildCargo.override {
      cargo = cargo_bootstrap;
      rustc = rustc_bootstrap;
      rust-std = rust-std_bootstrap;
    };
    fetchCargoDeps = self.fetchCargoDeps.override {
      cargo = cargo_bootstrap;
      cargo-vendor = cargo-vendor_bootstrap;
      rustc = rustc_bootstrap;
    };
    inherit channel;
  };

  cargo-vendor_bootstrap = callPackage ../all-pkgs/c/cargo-vendor/bootstrap.nix {
    buildCargo = self.buildCargo.override {
      cargo = cargo_bootstrap;
      rustc = rustc_bootstrap;
      rust-std = rust-std_bootstrap;
    };
  };

  rustc_bootstrap = callPackage ../all-pkgs/r/rustc/bootstrap.nix {
    rustc = self.rustc;
    rust-std = rust-std_bootstrap;
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

  fetchCrate = callPackage ../all-pkgs/c/cargo/fetch-crate.nix { };

  fetchCargoDeps = callPackage ../all-pkgs/c/cargo/fetch-deps.nix { };

  cargo = callPackage ../all-pkgs/c/cargo {
    buildCargo = self.buildCargo.override {
      cargo = cargo_bootstrap_patched;
    };
    fetchCargoDeps = self.fetchCargoDeps.override {
      cargo = cargo_bootstrap_patched;
      cargo-vendor = cargo-vendor_bootstrap;
    };
    inherit channel;
  };
  inherit cargo_bootstrap_patched;

  cargo-vendor = callPackage ../all-pkgs/c/cargo-vendor {
    fetchCargoDeps = self.fetchCargoDeps.override {
      cargo-vendor = cargo-vendor_bootstrap;
    };
  };

  # These packages are special in that they use the top-level callPackage since they aren't cargo packages
  rustc = callPackage ../all-pkgs/r/rustc {
    cargo = cargo_bootstrap_patched;
    rustc = rustc_bootstrap;
    inherit channel;
  };

  rust-std = callPackage ../all-pkgs/r/rust-std {
    buildCargo = self.buildCargo.override {
      cargo = cargo_bootstrap_patched;
      rust-std = null;
    };
  };

  ripgrep = callPackage ../all-pkgs/r/ripgrep { };

  }; in self
