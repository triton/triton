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
      ' ${pkgs.dnssec-root}/share/dnssec/iana-root.txt > $out
    '';

    preferLocalBuild = true;
    allowSubstitutes = false;
  };

  rootKeyFile = "${stateDir}/root.key";

  trustAnchor = optionalString cfg.enableRootTrustAnchor ''
    trust-anchor-file: "${rootKeyFile}"
  '';

  confFile' = pkgs.writeText "unbound.conf" ''
    include: ${stateDir}/unbound-*.conf
    server:
      directory: "${stateDir}"
      username: unbound
      pidfile: "/run/unbound.pid"
      chroot: "${stateDir}"
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
        rm -f ${confFile} ${rootKeyFile}
        cp ${confFile'} ${confFile}
        cp ${rootKeyFile'} ${rootKeyFile}
        touch ${stateDir}/unbound-resolvconf.conf

        mkdir -p ${stateDir}/dev
        touch ${stateDir}/dev/random
        mount -o defaults,bind /dev/urandom ${stateDir}/dev/random
      '';

      postStop = ''
        umount ${stateDir}/dev/random
      '';

      serviceConfig = {
        ExecStart = "${pkgs.unbound}/sbin/unbound -d -c ${confFile}";
      };
    };

  };

}
