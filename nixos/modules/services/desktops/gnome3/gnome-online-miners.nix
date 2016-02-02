{ config, pkgs, lib, ... }:

with {
  inherit (lib)
    mkIf
    mkOption
    types;
};

{

  options = {

    services.gnome-online-miners = {

      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable GNOME Online Miners, a service that
          crawls through your online content.
        '';
      };

    };

  };

  config = mkIf config.services.gnome-online-miners.enable {

    environment.systemPackages = [
      pkgs.gnome-online-miners
    ];

    services.dbus.packages = [
      pkgs.gnome-online-miners
    ];

  };

}
