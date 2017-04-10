{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.services.unbound;

  stateDir = "/var/lib/unbound";

  rootKeyFile' = pkgs.stdenv.mkDerivation {
    name = "unbound-root-key";

    buildCommand = ''
      awk '
      {
        if (/Domain:/) { domain=$2; }
        if (/Flags:/) { flags=$2; }
        if (/Protocol:/) { protocol=$2; }
        if (/Algorithm:/) { algorithm=$2; }
        if (/Key:/) { key=$2; }
      }
      END {
        print domain "   1000    IN DNSKEY  " flags " " protocol " " algorithm " " key;
      }
      ' ${pkgs.dnssec-root.file} > $out
    '';

    preferLocalBuild = true;
    allowSubstitutes = false;
  };

  rootKeyFile = "${stateDir}/root.key";
  rootHintsFile = "${stateDir}/root.hints";

  trustAnchor = optionalString cfg.enableRootTrustAnchor ''
    trust-anchor-file: "${rootKeyFile}"
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

      enableRootTrustAnchor = mkOption {
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
      path = [ pkgs.util-linux_full ];

      preStart = ''
        mkdir -p "${stateDir}"
        rm -f "${confFile}" "${rootKeyFile}" "${rootHintsFile}"
        cp "${confFile'}" "${confFile}"
      '' + optionalString cfg.enableRootTrustAnchor ''
        cp "${rootKeyFile'}" "${rootKeyFile}"
      '' + optionalString cfg.enableRootHints ''
        cp "${pkgs.root-nameservers.file}" "${rootHintsFile}"
      '' + ''
        touch ${stateDir}/unbound-resolvconf.conf

        mkdir -p ${stateDir}/dev
        touch ${stateDir}/dev/random
        mount -o defaults,bind /dev/urandom ${stateDir}/dev/random
        mount -o defaults,bind /dev/log ${stateDir}/dev/log
      '';

      postStop = ''
        umount ${stateDir}/dev/random
        umount ${stateDir}/dev/log
      '';

      serviceConfig = {
        ExecStart = "${pkgs.unbound}/sbin/unbound -d -c ${confFile}";
      };
    };

  };

}
