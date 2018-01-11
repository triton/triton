{ config, lib, pkgs, ... }:

with lib;
let
  stateDir = "/var/lib/chrony";

  cfg = config.services.chrony;

  cfgFile = pkgs.writeText "chrony.conf" ''
    ${concatMapStringsSep "\n" (server: "server " + server + " iburst") cfg.servers}

    ${optionalString cfg.initstepslew.enable ''
      initstepslew ${cfg.initstepslew.threshold} ${concatStringsSep " " cfg.initstepslew.servers}
      makestep ${cfg.initstepslew.threshold} 3
    ''}

    driftfile ${stateDir}/drift
    dumpdir ${stateDir}
    dumponexit

    hwclockfile /etc/adjtime
    rtcdevice /dev/rtc
    ${if cfg.exclusiveRTC then ''
      rtcfile ${stateDir}/rtc
    '' else ''
      rtcsync
    ''}

    ${optionalString (!cfg.remoteCmdAccess) ''
      cmdport 0
    ''}

    ${cfg.extraConfig}
  '';

  cmdline = [
    "@${pkgs.chrony}/bin/chronyd" "chronyd"
    "-n"
    "-m"
    "-r"
    "-s"
    "-u" "chrony"
    "-f" cfgFile
  ] ++ cfg.extraCmdline;
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

      initstepslew = {
        enable = mkOption {
          type = types.bool;
          default = false;
          description = ''
            Whether or not we should forcefully change the system time at start.
          '';
        };

        threshold = mkOption {
          type = types.str;
          default = "0.1";
          description = ''
            The threshold for stepping all at once instead of doing a gradual slew.
            The unit is seconds.
          '';
        };

        servers = mkOption {
          type = types.listOf types.str;
          default = cfg.servers;
          description = ''
            The servers to use for determining the slew / step at startup.
          '';
        };
      };

      exclusiveRTC = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Allow chrony to take exclusive ownership of the system
          real time clock so it can better measure the accuracy.
        '';
      };

      remoteCmdAccess = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Allow remove command access port to be open.
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
      conflicts = [ "ntpd.service" "systemd-timesyncd.service" ];

      preStart = ''
        mkdir -m 0755 -p "${stateDir}"
        chown chrony "${stateDir}"
      '';

      serviceConfig = {
        ExecStart = concatStringsSep " " cmdline;
      };
    };
  };

}
