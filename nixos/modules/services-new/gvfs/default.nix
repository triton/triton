{ config, lib, pkgs, ... }:

with {
  inherit (lib)
    mkIf
    mkOption
    types;
};

{

  options = {

    services.gvfs = {

      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable gvfs backends, userspace virtual filesystem used
          by GNOME components via D-Bus.
        '';
      };

    };

  };

  config = mkIf config.services.gvfs.enable {

    environment.systemPackages = [
      pkgs.gvfs
    ];

    services.dbus.packages = [
      pkgs.gvfs
    ];

    services.udev.packages = [
      pkgs.libmtp
    ];

  };

}
