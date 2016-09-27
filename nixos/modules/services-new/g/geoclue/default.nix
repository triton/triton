{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mkIf
    mkOption
    types;
in

{
  options = {

    services.geoclue = {

      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable GeoClue 2 daemon, a DBus service that provides
          location informationfor accessing.
        '';
      };

    };

  };

  config = mkIf config.services.geoclue.enable {

    environment.systemPackages = [
      pkgs.geoclue
    ];

    services.dbus.packages = [
      pkgs.geoclue
    ];

    systemd.packages = [
      pkgs.geoclue
    ];

  };
}
