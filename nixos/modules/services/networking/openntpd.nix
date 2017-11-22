{ pkgs, lib, config, options, ... }:

with lib;

let
  cfg = config.services.openntpd;

  package = pkgs.openntpd;

  cfgFile = pkgs.writeText "openntpd.conf" ''
    ${concatStringsSep "\n" (map (s: "server ${s}") cfg.servers)}
    ${cfg.extraConfig}
  '';

  cmdline = [
    "${package}/sbin/ntpd"
    "-d"
    "-f" cfgFile
  ] ++ cfg.extraCmdline;
in
{
  ###### interface

  options.services.openntpd = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        OpenNTP time synchronization server
      '';
    };

    servers = mkOption {
      default = config.services.ntp.servers;
      type = types.listOf types.str;
      inherit (options.services.ntp.servers) description;
    };

    extraConfig = mkOption {
      type = types.lines;
      default = "";
      example = ''
        listen on 127.0.0.1 
        listen on ::1 
      '';
      description = ''
        Additional text appended to <filename>openntpd.conf</filename>.
      '';
    };

    extraCmdline = mkOption {
      type = types.listOf types.str;
      default = [ ];
      example = [ "-s" ];
      description = ''
        Extra options used when launching openntpd.
      '';
    };
  };

  ###### implementation

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = !config.time.hardwareClockInLocalTime;
        message = "openntpd does not support local time RTC.";
      }
    ];

    # Add ntpctl to the environment for status checking
    environment.systemPackages = [
      package
    ];

    services.ntp.providers = [
      "openntpd"
    ];

    systemd.services.openntpd = {
      description = "OpenNTP Server";
      wantedBy = [
        "multi-user.target"
      ];
      wants = [
        "network-online.target"
      ];
      after = [
        "network-online.target"
      ];
      serviceConfig.ExecStart = concatStringsSep " " cmdline;
    };

    users.extraUsers = singleton {
      name = "ntp";
      uid = config.ids.uids.ntp;
      description = "OpenNTP daemon user";
      home = "/var/empty";
    };
  };
}
