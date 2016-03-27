{ config, lib, pkgs, ... }:

with {
  inherit (lib)
    mkIf
    mkOption
    types;
};

{

  options = {

    services.seahorse = {

      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable Seahorse search provider for the GNOME Shell activity search.
        '';
      };

    };

  };

  config = mkIf config.services.seahorse.enable {

    environment.systemPackages = [
      pkgs.seahorse
    ];

    services.dbus.packages = [
      pkgs.seahorse
    ];

  };

}
