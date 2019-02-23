{ config, lib, pkgs, ... }:

let
  inherit (lib)
    concatStringsSep
    mkIf
    mkOption
    optionals
    optionalAttrs;

  inherit (lib.types)
    attrs
    bool
    str;

  cfg = config.services.ipfs;

  ipfs_path = "/var/lib/ipfs";

  privateAddrs = [
    "/ip4/10.0.0.0/ipcidr/8"
    "/ip4/100.64.0.0/ipcidr/10"
    "/ip4/127.0.0.0/ipcidr/8"
    "/ip4/169.254.0.0/ipcidr/16"
    "/ip4/172.16.0.0/ipcidr/12"
    "/ip4/192.0.0.0/ipcidr/24"
    "/ip4/192.0.0.0/ipcidr/29"
    "/ip4/192.0.0.8/ipcidr/32"
    "/ip4/192.0.0.170/ipcidr/32"
    "/ip4/192.0.0.171/ipcidr/32"
    "/ip4/192.0.2.0/ipcidr/24"
    "/ip4/192.168.0.0/ipcidr/16"
    "/ip4/198.18.0.0/ipcidr/15"
    "/ip4/198.51.100.0/ipcidr/24"
    "/ip4/203.0.113.0/ipcidr/24"
    "/ip4/240.0.0.0/ipcidr/4"
    "/ip6/::1/ipcidr/128"
    "/ip6/fc00::/ipcidr/7"
    "/ip6/fe00::/ipcidr/10"
  ];

  filterAddrs = if cfg.privateAddresses then [ ] else privateAddrs;

  extraJson = pkgs.writeText "ipfs-extra.json" (builtins.toJSON cfg.extraAttrs);

  extraFlags = [
  ] ++ optionals cfg.gc [
    "--enable-gc"
  ];
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

      quic = mkOption {
        type = bool;
        default = true;
        description = ''
          Enable the experimental QUIC protocol.
        '';
      };

      privateAddresses = mkOption {
        type = bool;
        default = false;
        description = ''
          Should we allow and advertise private addresses.
        '';
      };

      gc = mkOption {
        type = bool;
        default = true;
        description = ''
          Enable the periodic garbage collector.
        '';
      };

      extraAttrs = mkOption {
        type = attrs;
        default = { };
        description = ''
          Extra attrs to pass when generating the JSON config.
        '';
      };

    };

  };

  config = mkIf cfg.enable {

    environment.variables = {
      IPFS_PATH = ipfs_path;
    };

    networking.proxy.envVars.IPFS_API = "127.0.0.1:8001";

    services.ipfs.extraAttrs = {
      Addresses = {
        Swarm = [
          "/ip4/0.0.0.0/tcp/4001"
          "/ip6/::/tcp/4001"
        ] ++ optionals cfg.quic [
          "/ip4/0.0.0.0/udp/4001/quic"
          "/ip6/::/udp/4001/quic"
        ];
        API = "/ip4/127.0.0.1/tcp/5001";
        Gateway = "/ip4/127.0.0.1/tcp/8001";
        NoAnnounce = filterAddrs;
      };
      Discovery.MDNS.Enabled = false;
      Swarm.AddrFilters = filterAddrs;
      Experimental.QUIC = cfg.quic;
    };

    systemd.services.ipfs = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      path = with pkgs; [
        gawk
        gnused
        findutils
        fs-repo-migrations
        ipfs
        jq
        util-linux_full
      ];

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

        # We shouldn't have a stale API file
        # Leaving this around will break all ipfs commands prior to starting the daemon
        rm -f "${ipfs_path}/api"

        if [ ! -e "${ipfs_path}/config" ]; then
          echo "Missing config file: ${ipfs_path}/config" >&2
          echo "You can fix this by running `ipfs init -e` and copying the config from \$HOME/.ipfs/config" >&2
          echo "Or you can delete all of the file in ${ipfs_path} and restart the service" >&2
          exit 6
        fi

        su ipfs -s /bin/sh -c "fs-repo-migrations -y -to $(ipfs repo version -q | sed 's,fs-repo@\([0-9]\+\),\1,g')"

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
        LimitNOFILE = "infinity";
        PermissionsStartOnly = true;
        UMask = "0027";
        Restart = "on-failure";
        RestartPreventExitStatus = "6";
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
