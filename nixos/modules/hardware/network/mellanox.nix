{ config, lib, pkgs, ... }:

with lib;

{

  ###### interface

  options = {

    hardware.mellanox-tools.enable = mkOption {
      default = false;
      type = types.bool;
      description = ''
        Turn on this option if you want to enable mellanox tooling on this machine.
      '';
    };

  };


  ###### implementation

  config = mkIf config.hardware.mellanox-tools.enable {
    boot.extraModulePackages = [
      config.boot.kernelPackages.mft
    ];

    environment.systemPackages = [
      pkgs.mft
    ];

    systemd.services."mst" = {
      description = "Enablement for mellanox devices";
      wantedBy = [ "multi-user.target" ];
      environment.MODULE_DIR = "/run/booted-system/kernel-modules/lib/modules";
      path = [
        pkgs.coreutils
        pkgs.kmod
        pkgs.mft
        pkgs.pciutils
        pkgs.usbutils
      ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "@${pkgs.mft}/bin/mst mst start";
      };
    };
  };

}
