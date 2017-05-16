{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.services.unbound;

  stateDir = "/var/lib/unbound";

  rootKeyFile = "${stateDir}/root.key";
  rootHintsFile = "${stateDir}/root.hints";

  trustAnchor = optionalString cfg.enableAutoTrustAnchor ''
    auto-trust-anchor-file: "${rootKeyFile}"
  '';

  rootHints = optionalString cfg.enableRootHints ''
    root-hints: "${rootHintsFile}"
  '';

  confFile' = pkgs.writeText "unbound.conf" ''
    include: ${stateDir}/unbound-*.conf
    server:
      directory: "${stateDir}"
      username: unbound
      pidfile: "/run/unbound.pid"
      chroot: "${stateDir}"
      ${rootHints}
      ${trustAnchor}
    ${cfg.extraConfig}
  '';

  confFile = "${stateDir}/unbound.conf";

in

{

  ###### interface

  options = {
    services.unbound = {

      enable = mkOption {
        default = false;
        type = types.bool;
        description = "Whether to enable the Unbound domain name server.";
      };

      enableRootHints = mkOption {
        default = false;
        type = types.bool;
        description = "Use root hints in case forwarding fails";
      };

      enableAutoTrustAnchor = mkOption {
        default = true;
        type = types.bool;
        description = "Use and update root trust anchor for DNSSEC validation.";
      };

      extraConfig = mkOption {
        default = "";
        type = types.lines;
        description = "Extra lines of unbound config.";
      };

    };
  };

  ###### implementation

  config = mkIf cfg.enable {

    networking.extraResolvconfConf = ''
      unbound_conf=${stateDir}/unbound-resolvconf.conf
    '';

    users.extraUsers = singleton {
      name = "unbound";
      uid = config.ids.uids.unbound;
      description = "unbound daemon user";
      home = stateDir;
      createHome = true;
    };

    systemd.services.unbound = {
      description="Unbound recursive Domain Name Server";
      before = [ "network-setup.service" ];
      wantedBy = [ "multi-user.target" ];
      path = [
        pkgs.unbound
        pkgs.util-linux_full
      ];

      preStart = ''
        mkdir -p "${stateDir}"
        rm -f "${confFile}" "${rootHintsFile}"
        cp "${confFile'}" "${confFile}"
      '' + optionalString cfg.enableAutoTrustAnchor ''
        if [ ! -e root.key ]; then
          unbound-anchor -l | grep '\. IN DS' > "${rootKeyFile}"
        fi
      '' + optionalString cfg.enableRootHints ''
        cp "${pkgs.root-nameservers.file}" "${rootHintsFile}"
      '' + ''
        touch ${stateDir}/unbound-resolvconf.conf

        mkdir -p ${stateDir}/dev
        touch ${stateDir}/dev/random
        mount -o defaults,bind /dev/urandom ${stateDir}/dev/random
        touch ${stateDir}/dev/log
        mount -o defaults,bind /dev/log ${stateDir}/dev/log
      '';

      postStop = ''
        umount ${stateDir}/dev/random || true
        umount ${stateDir}/dev/log || true
      '';

      serviceConfig = {
        ExecStart = "${pkgs.unbound}/sbin/unbound -d -c ${confFile}";
      };
    };

  };

}
