{ config, lib, pkgs, ... }:

let
  cfg = config.services.ipfs-cluster;

  data_path = "/var/lib/ipfs-cluster";

  inherit (lib)
    mkIf
    mkOption;

  inherit (lib.types)
    bool;
in
{
  options = {

    services.ipfs-cluster = {

      enable = mkOption {
        type = bool;
        default = false;
        description = ''
          Enable the ipfs-cluster daemon process.
        '';
      };

    };

  };

  config = mkIf cfg.enable {

    systemd.services.ipfs-cluster = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      path = with pkgs; [
        coreutils
        ipfs-cluster
      ];

      preStart = ''
        umask 0077
        if [ -e '${data_path}' ]; then
          mkdir -p '${data_path}'

          # Initialize the repo
          ipfs-cluster-service init

          # Fix permissions
          chown -R ipfs-cluster '${data_path}'
        fi
      '';

      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.ipfs-cluster}/bin/ipfs-cluster-service daemon";
        User = "ipfs-cluster";
        PermissionsStartOnly = true;
        UMask = "0077";
        Restart = "on-failure";
      };
    };

    users.extraUsers.ipfs-cluster = {
      uid = config.ids.uids.ipfs-cluster;
    };
  };
}
