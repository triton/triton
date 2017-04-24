{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.etcd;

  configFile = pkgs.writeText "etcd.conf.yaml" (''
    name: '${cfg.name}'
    data-dir: '${cfg.dataDir}'
  '' + optionalString (cfg.initialAdvertisePeerUrls != null) ''
    initial-advertise-peer-urls: ${concatStringsSep "," cfg.initialAdvertisePeerUrls}
  '' + optionalString (cfg.advertiseClientUrls != null) ''
    advertise-client-urls: ${concatStringsSep "," cfg.advertiseClientUrls}
  '' + optionalString (cfg.listenClientUrls != null) ''
    listen-client-urls: ${concatStringsSep "," cfg.listenClientUrls}
  '' + optionalString (cfg.listenPeerUrls != null) ''
    listen-peer-urls: ${concatStringsSep "," cfg.listenPeerUrls}
  '' + optionalString (cfg.initialCluster != null) ''
    initial-cluster: ${concatStringsSep "," (mapAttrsToList (n: u: "${n}=${u}") cfg.initialCluster)}
  '' + optionalString (cfg.initialClusterState != null) ''
    initial-cluster-state: ${cfg.initialClusterState}
  '' + optionalString (cfg.initialClusterToken != null) ''
    initial-cluster-token: ${cfg.initialClusterToken}
  '' + ''
    strict-reconfig-check: true
    enable-v2: false
    client-transport-security:
    peer-transport-security:
  '');
in
{

  options.services.etcd = {

    enable = mkOption {
      description = "Whether to enable etcd.";
      default = false;
      type = types.bool;
    };

    name = mkOption {
      description = "Etcd unique node name.";
      default = config.networking.hostName;
      type = types.str;
    };

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/etcd";
      description = "Etcd data directory.";
    };

    advertiseClientUrls = mkOption {
      description = "Etcd list of this member's client URLs to advertise to the rest of the cluster.";
      default = cfg.listenClientUrls;
      type = types.nullOr (types.listOf types.str);
    };

    listenClientUrls = mkOption {
      description = "Etcd list of URLs to listen on for client traffic.";
      default = null;
      type = types.nullOr (types.listOf types.str);
    };

    listenPeerUrls = mkOption {
      description = "Etcd list of URLs to listen on for peer traffic.";
      default = null;
      type = types.nullOr (types.listOf types.str);
    };

    initialAdvertisePeerUrls = mkOption {
      description = "Etcd list of this member's peer URLs to advertise to rest of the cluster.";
      default = cfg.listenPeerUrls;
      type = types.nullOr (types.listOf types.str);
    };

    initialCluster = mkOption {
      description = "Etcd initial cluster configuration for bootstrapping.";
      default = null;
      type = types.nullOr (types.attrsOf types.str);
    };

    initialClusterState = mkOption {
      description = "Etcd initial cluster configuration for bootstrapping.";
      default = null;
      type = types.nullOr (types.enum ["new" "existing"]);
    };

    initialClusterToken = mkOption {
      description = "Etcd initial cluster token for etcd cluster during bootstrap.";
      default = null;
      type = types.nullOr types.str;
    };

    discovery = mkOption {
      description = "Etcd discovery url";
      default = "";
      type = types.str;
    };
  };

  config = mkIf cfg.enable {

    systemd.services.etcd = {
      description = "Etcd Daemon";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      serviceConfig = {
        Type = "notify";
        ExecStart = "@${pkgs.etcd}/bin/etcd etcd --config-file ${configFile}";
        User = "etcd";
        PermissionsStartOnly = true;
      };

      preStart = ''
        mkdir -m 0700 -p ${cfg.dataDir}
        chown etcd ${cfg.dataDir};
      '';
    };

    environment.systemPackages = [
      pkgs.etcd
    ];

    users.extraUsers = singleton {
      name = "etcd";
      uid = config.ids.uids.etcd;
      description = "Etcd daemon user";
      home = cfg.dataDir;
    };

  };
}
