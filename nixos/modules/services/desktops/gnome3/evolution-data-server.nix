{ config, lib, pkgs, ... }:

with {
  inherit (lib)
    mkIf
    mkOption
    types;
};

{

  options = {

    services.evolution-data-server = {

      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable Evolution Data Server, a collection of services for
          storing addressbooks and calendars.
        '';
      };

    };

  };

  config = mkIf config.services.evolution-data-server.enable {

    environment.systemPackages = [
      pkgs.evolution-data-server
    ];

    services.dbus.packages = [
      pkgs.evolution-data-server
    ];

  };

}
