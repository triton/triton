{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mkIf
    mkOption
    types;
in

{
  options = {

    services.dconf = {

      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable dconf service.
        '';
      };

    };

  };

  config = mkIf config.services.dconf.enable {

    environment.systemPackages = [
      pkgs.dconf
    ];

    services.dbus.packages = [
      pkgs.dconf
    ];

  };
}
