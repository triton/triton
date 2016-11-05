{ config, lib, pkgs, ... }:

with lib;

let

  inherit (pkgs) ntp;

  cfg = config.services.ntp;

  stateDir = "/var/lib/ntp";

  ntpUser = "ntp";

  configFile = pkgs.writeText "ntp.conf" ''
    driftfile ${stateDir}/ntp.drift

    restrict 127.0.0.1
    restrict -6 ::1

    ${toString (map (server: "server " + server + " iburst\n") cfg.servers)}
  '';

  cmdline = [
    "@${ntp}/bin/ntpd" "ntpd"
    "-g"
    "-c" configFile
    "-u" "${ntpUser}:nogroup"
  ] ++ cfg.extraCmdline;

in

{

  ###### interface

  options = {

    services.ntp = {

      enable = mkOption {
        default = false;
        type = types.bool;
        description = ''
          Whether to synchronise your machine's time using the NTP
          protocol.
        '';
      };

      providers = mkOption {
        default = [ ];
        type = types.listOf types.str;
        description = ''
          This is for internal use only to describe the name of the
          ntp providing service.
        '';
      };

      servers = mkOption {
        type = types.listOf types.str;
        default = [
          "0.nixos.pool.ntp.org"
          "1.nixos.pool.ntp.org"
          "2.nixos.pool.ntp.org"
          "3.nixos.pool.ntp.org"
        ];
        description = ''
          The set of NTP servers from which to synchronise.
        '';
      };

      extraCmdline = mkOption {
        type = types.listOf types.str;
        description = "Extra flags passed to the ntpd command.";
        default = [ ];
      };

    };

  };


  ###### implementation

  config = mkMerge [
    {
      assertions = [
        {
          assertion = length cfg.providers <= 1;
          message = "You can only have a single ntp provider, not: ${toString cfg.providers}";
        }
      ];
    }
    (mkIf config.services.ntp.enable {
      assertions = [
        {
          assertion = !config.time.hardwareClockInLocalTime;
          message = "ntpd does not support local time RTC.";
        }
      ];

      environment.systemPackages = [
        pkgs.ntp
      ];

      services.ntp.providers = [
        "ntp"
      ];

      systemd.services.ntpd = {
        description = "NTP Daemon";
        wantedBy = [
          "multi-user.target"
        ];
        preStart = ''
          mkdir -m 0755 -p ${stateDir}
          chown ${ntpUser} ${stateDir}
        '';
        serviceConfig = {
          Type = "forking";
          ExecStart = concatStringsSep " " cmdline;
        };
      };

      users.extraUsers."${ntpUser}" = {
        uid = config.ids.uids.ntp;
        description = "NTP daemon user";
        home = stateDir;
      };
    })
  ];

}
