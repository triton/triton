{ config, lib, pkgs, ... }:

with lib;
let
  stateDir = "/var/lib/chrony";

  keyFile = "${stateDir}/chrony.keys";

  cfg = config.services.chrony;

  cfgFile = pkgs.writeText "chrony.conf" ''
    ${concatMapStringsSep "\n" (server: "server " + server + " iburst") cfg.servers}

    ${optionalString (!config.time.hardwareClockInLocalTime) "rtconutc"}

    ${cfg.extraConfig}
  '';

  cmdline = [
    "@${pkgs.chrony}/bin/chronyd" "chronyd"
    "-n"
    "-m"
    "-u" "chrony"
    "-f" cfgFile
  ] ++ extraCmdline;
in
{

  ###### interface

  options = {

    services.chrony = {

      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to synchronise your machine's time using chrony.
          Make sure you disable NTP if you enable this service.
        '';
      };

      servers = mkOption {
        type = types.listOf types.str;
        default = config.services.ntp.servers;
        description = ''
          The set of NTP servers from which to synchronise.
        '';
      };

      extraCmdline = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = ''
          Extra arguments to pass to chronyd
        '';
      };

      extraConfig = mkOption {
        type = types.lines;
        default = "";
        description = ''
          Extra configuration directives that should be added to
          <literal>chrony.conf</literal>
        '';
      };
    };

  };


  ###### implementation

  config = mkIf config.services.chrony.enable {
    services.ntp.providers = [
      "chrony"
    ];

    # Make chronyc available in the system path
    environment.systemPackages = [
      pkgs.chrony
    ];

    users.extraGroups.chrony = {
      gid = config.ids.gids.chrony;
    };

    users.extraUsers.chrony = {
      uid = config.ids.uids.chrony;
      group = "chrony";
      description = "chrony daemon user";
      home = stateDir;
    };

    systemd.services.chronyd = {
      description = "chrony NTP daemon";

      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      conflicts = [ "ntpd.service" "systemd-timesyncd.service" ];

      preStart = ''
        mkdir -m 0755 -p ${stateDir}
        touch ${keyFile}
        chmod 0640 ${keyFile}
        chown chrony:chrony ${stateDir} ${keyFile}
      '';

      serviceConfig = {
        ExecStart = concatStringsSep " " cmdline;
      };
    };
  };

}
