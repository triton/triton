{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mkIf
    mkOption
    types;
in

{
  options = {

    services.at-spi2-core = {

      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable at-spi2-core, a service for the Assistive
          Technologies available on the GNOME platform.
        '';
      };

    };

  };

  config = mkIf config.services.at-spi2-core.enable {

    environment.systemPackages = [
      pkgs.at-spi2-core
    ];

    services.dbus.packages = [
      pkgs.at-spi2-core
    ];

  };
}
