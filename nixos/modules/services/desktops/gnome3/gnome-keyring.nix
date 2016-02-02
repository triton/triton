{ config, pkgs, lib, ... }:

with {
  inherit (lib)
    mkIf
    mkOption
    types;
};

{

  options = {

    services.gnome-keyring = {

      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable GNOME Keyring daemon, a service designed to
          take care of the user's security credentials,
          such as user names and passwords.
        '';
      };

    };

  };

  config = mkIf config.services.gnome-keyring.enable {

    environment.systemPackages = [
      pkgs.gnome_keyring
    ];

    services.dbus.packages = [
      pkgs.gnome_keyring
    ];

  };

}
