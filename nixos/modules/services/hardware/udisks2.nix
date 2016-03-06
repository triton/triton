# Udisks daemon.

{ config, lib, pkgs, ... }:

with lib;

{

  ###### interface

  options = {

    services.udisks = {

      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable Udisks, a DBus service that allows
          applications to query and manipulate storage devices.
        '';
      };

    };

  };


  ###### implementation

  config = mkIf config.services.udisks.enable {

    environment.systemPackages = [ pkgs.udisks ];

    services.dbus.packages = [ pkgs.udisks ];

    system.activationScripts.udisks2 = ''
      mkdir -m 0755 -p /var/lib/udisks
    '';

    services.udev.packages = [ pkgs.udisks ];
    
    systemd.services.udisks = {
      description = "Udisks service";
      serviceConfig = {
        Type = "dbus";
        BusName = "org.freedesktop.UDisks2";
        ExecStart = "${pkgs.udisks}/libexec/udisks/udisksd --no-debug";
      };
    };
  };

}
