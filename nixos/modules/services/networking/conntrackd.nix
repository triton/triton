{ config, lib, pkgs, ... }:

let
  inherit (lib)
    concatMapStrings
    flip
    mkIf
    mkOption;

  inherit (lib.types)
    bool
    listOf
    str;

  cfg = config.services.conntrackd;

  configTxt = ''
    Sync {
      Mode FTFW {
        DisableExternalCache Off
        CommitTimeout 1800
        PurgeTimeout 5
      }

  '' + flip concatMapStrings cfg.remoteAddresses (n: ''
      UDP {
        IPv4_address ${cfg.localAddress}
        IPv4_Destination_Address ${n}
        Port 3780
        Interface ${cfg.interface}
        SndSocketBuffer 24985600
        RcvSocketBuffer 24985600
        Checksum on
      }
  '') + ''
    }

    General {
      Nice -20
      HashSize 32768
      HashLimit 131072
      LogFile on
      Syslog on
      LockFile /run/conntrack.lock
      UNIX {
        Path /run/conntrack.ctl
        Backlog 20
      }
      NetlinkBufferSize 2097152
      NetlinkBufferSizeMaxGrowth 8388608
      Filter From Userspace {
        Protocol Accept {
          TCP
          UDP
          ICMP
        }
        Address Ignore {
  '' + flip concatMapStrings cfg.ignoreAddresses (n:
    "      IPv4_address ${n}\n"
  ) + ''
        }
      }
    }
  '';
in
{
  options = {

    services.conntrackd = {

      enable = mkOption {
        type = bool;
        default = false;
        description = ''
          Enables the conntrack daemon.
        '';
      };

      ignoreAddresses = mkOption {
        type = listOf str;
        default = [
          "127.0.0.1"
        ];
        description = ''
          Ignore these addresses when syncing state
        '';
      };

      interface = mkOption {
        type = str;
        description = ''
          The interface to send UDP packets on.
        '';
      };

      localAddress = mkOption {
        type = str;
        description = ''
          The address we send our sync packets from.
        '';
      };

      remoteAddresses = mkOption {
        type = listOf str;
        description = ''
          The remote addresses to sync with.
        '';
      };

    };

  };

  config = mkIf cfg.enable {

    environment.etc."conntrackd/conntrackd.conf".text = configTxt;

    systemd.services.conntrackd = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      restartTriggers = [ config.environment.etc."conntrackd/conntrackd.conf".source ];
      serviceConfig = {
        ExecStart = "${pkgs.conntrack-tools}/bin/conntrackd";
      };
    };

  };
}
