{ lib
, channel
, newScope
, pkgs
}:

let
  callPackage = newScope (self // {
    inherit pkgs;
    goPackages = self;
  });

  self = {

  # Core packages for building all of the rest
  go = callPackage ../all-pkgs/g/go {
    inherit channel;
  };
  buildGo = callPackage ../all-pkgs/g/go/build.nix { };
  fetchGo = callPackage ../all-pkgs/g/go/fetch.nix { };

  # Packages
  consul = callPackage ../all-pkgs/c/consul { };

  consul-template = callPackage ../all-pkgs/c/consul-template { };

  dnscrypt-proxy = callPackage ../all-pkgs/d/dnscrypt-proxy { };

  elvish = callPackage ../all-pkgs/e/elvish { };

  etcd = callPackage ../all-pkgs/e/etcd { };

  hugo = callPackage ../all-pkgs/h/hugo { };

  ipfs = callPackage ../all-pkgs/i/ipfs { };

  ipfs-cluster = callPackage ../all-pkgs/i/ipfs-cluster { };

  ipfs-ds-convert = callPackage ../all-pkgs/i/ipfs-ds-convert { };

  lego = callPackage ../all-pkgs/l/lego { };

  mc = callPackage ../all-pkgs/m/mc { };

  minio = callPackage ../all-pkgs/m/minio { };

  nomad = callPackage ../all-pkgs/n/nomad { };

  rclone = callPackage ../all-pkgs/r/rclone { };

  syncthing = callPackage ../all-pkgs/s/syncthing { };

  teleport = callPackage ../all-pkgs/t/teleport { };

  vault = callPackage ../all-pkgs/v/vault { };

  }; in self
