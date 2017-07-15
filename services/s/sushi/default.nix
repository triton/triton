{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mkIf
    mkOption
    types;
in

{
  options = {

    services.sushi = {

      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable Sushi, a quick previewer for nautilus.
        '';
      };

    };

  };

  config = mkIf config.services.sushi.enable {

    environment.systemPackages = [
      pkgs.sushi
    ];

    services.dbus.packages = [
      pkgs.sushi
    ];

  };
}
