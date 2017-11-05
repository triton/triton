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

    environment.etc."libblockdev/conf.d/00-default.cfg".source =
      "${pkgs.libblockdev}/etc/libblockdev/conf.d/00-default.cfg";

    environment.etc."libblockdev/conf.d/10-lvm-dbus.cfg".source =
      "${pkgs.libblockdev}/etc/libblockdev/conf.d/10-lvm-dbus.cfg";

    # TODO: make configurable
    environment.etc."udisks2/udisks2.conf".source =
      "${pkgs.udisks}/etc/udisks2/udisks2.conf";

    # TODO: make configurable
    environment.etc."udisks2/modules.conf.d/udisks2_lsm.conf".source =
      "${pkgs.udisks}/etc/udisks2/modules.conf.d/udisks2_lsm.conf";

    environment.systemPackages = [
      pkgs.udisks
    ];

    services.dbus.packages = [
      pkgs.udisks
    ];

    system.activation.scripts.udisks = ''
      mkdir -m 0755 -p /var/lib/udisks
    '';

    systemd.packages = [
      pkgs.udisks
    ];

    services.udev.packages = [
      pkgs.udisks
    ];
  };

}
