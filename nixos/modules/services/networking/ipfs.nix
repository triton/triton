{ config, lib, pkgs, ... }:

let
  cfg = config.services.ipfs;

  ipfs_path = "/var/lib/ipfs";

  attrs = {
    Addresses = {
      Swarm = [
        "/ip4/0.0.0.0/tcp/4001"
      ] ++ optionals cfg.utp [
        "/ip4/0.0.0.0/udp/4001/utp"
      ] ++ [
        "/ip6/::/tcp/4001"
      ] ++ optionals cfg.utp [
        "/ip6/::/udp/4001/utp"
      ];
      API = "/ip4/127.0.0.1/tcp/5001";
      Gateway = "/ip4/127.0.0.1/tcp/8001";
    };
  };

  extraJson = pkgs.writeText "ipfs-extra.json" (builtins.toJSON attrs);

  extraFlags = [
  ] ++ optionals cfg.gc [
    "--enable-gc"
  ];

  inherit (lib)
    concatStringsSep
    mkIf
    mkOption
    optionals;

  inherit (lib.types)
    bool
    str;
in
{
  options = {

    services.ipfs = {

      enable = mkOption {
        type = bool;
        default = false;
        description = ''
          Enable the ipfs daemon process.
        '';
      };

      utp = mkOption {
        type = bool;
        default = true;
        description = ''
          Enable the experimental utp protocol.
        '';
      };

      gc = mkOption {
        type = bool;
        default = true;
        description = ''
          Enable the periodic garbage collector.
        '';
      };

    };

  };

  config = mkIf cfg.enable {

    environment.variables = {
      IPFS_API = "127.0.0.1:8001";
      IPFS_PATH = "/var/lib/ipfs";
    };

    systemd.services.ipfs = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      path = with pkgs; [ ipfs gawk findutils jq ];

      preStart = ''
        if [ "$(ls "${ipfs_path}" | wc -l)" -eq "0" ]; then
          mkdir -p "${ipfs_path}"
          chmod 0700 "${ipfs_path}"

          # Initialize the repo
          ipfs init -b 4096 -e

          # Remove any pins that are created by default
          ipfs pin ls -t recursive | awk '{print $1}' | xargs ipfs pin rm

          # Fix permissions
          chmod -R o-rwx "${ipfs_path}"
          chmod -R g-w "${ipfs_path}"
          chown -R ipfs:ipfs "${ipfs_path}"
          chmod 0750 "${ipfs_path}"
        fi

        if [ ! -e "${ipfs_path}/config" ]; then
          echo "Missing config file: ${ipfs_path}/config" >&2
          exit 1
        fi
        touch "${ipfs_path}/new_config"
        chmod 0660 "${ipfs_path}/new_config"
        chown ipfs:ipfs "${ipfs_path}/new_config"
        jq -s '.[0] * .[1]' "${ipfs_path}/config" "${extraJson}" > "${ipfs_path}/new_config"
        mv "${ipfs_path}"/{new_,}config
      '';

      environment.IPFS_PATH = ipfs_path;

      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.ipfs}/bin/ipfs daemon ${concatStringsSep " " extraFlags}";
        User = "ipfs";
        PermissionsStartOnly = true;
        UMask = "0027";
      };
    };

    users.extraUsers.ipfs = {
      uid = config.ids.uids.ipfs;
      group = "ipfs";
    };

    users.extraGroups.ipfs = {
      gid = config.ids.gids.ipfs;
    };
  };
}
