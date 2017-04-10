# This module generates nixos-install, nixos-rebuild,
# nixos-generate-config, etc.

{ config, pkgs, modulesPath, ... }:

let
  makeProg = args: pkgs.substituteAll (args // {
    dir = "bin";
    isExecutable = true;
  });

  nixos-build-vms = makeProg {
    name = "nixos-build-vms";
    src = ./nixos-build-vms/nixos-build-vms.sh;
  };

  nixos-install = makeProg {
    name = "nixos-install";
    src = ./nixos-install.sh;

    inherit (pkgs) perl pathsFromGraph rsync;
    nix = config.nix.package;
    root_uid = config.ids.uids.root;
    nixbld_gid = config.ids.gids.nixbld;

    nixClosure = pkgs.runCommand "closure"
      { exportReferencesGraph = ["refs" config.nix.package]; }
      "cp refs $out";
  };

  nixos-rebuild = makeProg {
    name = "nixos-rebuild";
    src = ./nixos-rebuild.sh;
    nix = config.nix.package;
  };

  nixos-generate-config = makeProg {
    name = "nixos-generate-config";
    src = ./nixos-generate-config.pl;
    path = [ pkgs.btrfs-progs ];
    perl = "${pkgs.perl}/bin/perl -I${pkgs.perlPackages.FileSlurp}/${pkgs.perlPackages.perl.libPrefix}";
    inherit (config.system) nixosRelease;
  };

  nixos-option = makeProg {
    name = "nixos-option";
    src = ./nixos-option.sh;
  };

  nixos-version = makeProg {
    name = "nixos-version";
    src = ./nixos-version.sh;
    inherit (config.system)
      nixosCodeName
      nixosRevision
      nixosVersion;
  };
in
{

  config = {

    environment.systemPackages =
      [ nixos-build-vms
        nixos-install
        nixos-rebuild
        nixos-generate-config
        nixos-option
        nixos-version
      ];

    system.build = {
      inherit
        nixos-generate-config
        nixos-install
        nixos-option
        nixos-rebuild;
    };

  };

}
