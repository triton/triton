{ config, pkgs, lib, ... }:

with {
  inherit (lib)
    mkIf
    mkOption
    types;
};

{

  options = {

    services.gnome-online-accounts = {

      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable GNOME Online Accounts daemon, a service that provides
          a single sign-on framework for the GNOME desktop.
        '';
      };

    };

  };

  config = mkIf config.services.gnome-online-accounts.enable {

    environment.systemPackages = [
      pkgs.gnome-online-accounts
    ];

    services.dbus.packages = [
      pkgs.gnome-online-accounts
    ];

  };

}
