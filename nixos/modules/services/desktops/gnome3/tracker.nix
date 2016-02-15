{ config, lib, pkgs, ... }:

with {
  inherit (lib)
    mkIf
    mkOption
    types;
};

{

  options = {

    services.tracker = {

      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable Tracker services, a search engine,
          search tool and metadata storage system.
        '';
      };

    };

  };

  config = mkIf config.services.tracker.enable {

    environment.systemPackages = [
      pkgs.tracker
    ];

    services.dbus.packages = [
      pkgs.tracker
    ];

  };

}
