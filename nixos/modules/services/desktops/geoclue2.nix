{ config, lib, pkgs, ... }:

with {
  inherit (lib)
    mkIf
    mkOption
    types;
};

{

  options = {

    services.geoclue2 = {

      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable GeoClue 2 daemon, a DBus service
          that provides location informationfor accessing.
        '';
      };

    };

  };

  config = mkIf config.services.geoclue2.enable {

    environment.systemPackages = [
      pkgs.geoclue2
    ];

    services.dbus.packages = [
      pkgs.geoclue2
    ];

    systemd.packages = [
      pkgs.geoclue2
    ];

  };

}
