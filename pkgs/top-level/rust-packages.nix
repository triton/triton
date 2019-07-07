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
      rustc = rustc_bootstrap;
    };
    inherit channel;
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
    };
    inherit channel;
  };
  inherit cargo_bootstrap_patched;

  # These packages are special in that they use the top-level callPackage since they aren't cargo packages
  rustc = callPackage ../all-pkgs/r/rustc {
    cargo = cargo_bootstrap_patched;
    rustc = rustc_bootstrap;
    inherit channel;
  };

  rust-proc-macro = callPackage ../all-pkgs/r/rust-proc-macro { };

  rust-std = callPackage ../all-pkgs/r/rust-std {
    buildCargo = self.buildCargo.override {
      cargo = cargo_bootstrap_patched;
      rust-std = null;
    };
  };

  alacritty = callPackage ../all-pkgs/a/alacritty { };

  ripgrep = callPackage ../all-pkgs/r/ripgrep { };

  }; in self
