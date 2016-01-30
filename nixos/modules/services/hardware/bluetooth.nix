{ config, lib, pkgs, ... }:

with lib;

{

  ###### interface

  options = {

    hardware.bluetooth.enable = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to enable support for Bluetooth.";
    };

  };


  ###### implementation

  config = mkIf config.hardware.bluetooth.enable {

    services.udev.packages = [ pkgs.bluez ];

    services.dbus.packages = [ pkgs.bluez ];

    systemd.services."dbus-org.bluez" = {
      description = "Bluetooth Service";
      serviceConfig = {
        Type = "dbus";
        BusName = "org.bluez";
        ExecStart = "${pkgs.bluez}/sbin/bluetoothd -n";
      };
      wantedBy = [ "bluetooth.target" ];
    };

  };

}
