{ config, pkgs, ... }:

{
  imports = [
    /conf/nixos/common/base.nix
    /conf/nixos/common/sshd.nix
    ./installation-cd-minimal.nix
  ];

  fileSystems."/iso".options = "defaults,x-systemd.device-timeout=0";

  systemd.services.sshd.wantedBy = pkgs.lib.mkOverride 0 [ "multi-user.target" ];
  systemd.services.systemd-udev-settle.serviceConfig.TimeoutSec = 0;
}
