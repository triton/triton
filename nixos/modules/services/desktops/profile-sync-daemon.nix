{ config, pkgs, lib, ... }:

with {
  inherit (lib)
    mkIf
    mkOption
    listOf
    types;
};

let
  cfg = config.services.psd;

  configFile = ''
    ${optionalString (cfg.users != [ ]) ''
      USERS="${concatStringsSep " " cfg.users}"
    ''}

    ${optionalString (cfg.browsers != [ ]) ''
      BROWSERS="${concatStringsSep " " cfg.browsers}"
    ''}

    ${optionalString (cfg.volatile != "") "VOLATILE=${cfg.volatile}"}
    ${optionalString (cfg.daemonFile != "") "DAEMON_FILE=${cfg.daemonFile}"}
  '';

in

{

  options.services.psd = {

    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether to enable the Profile Sync daemon.
      '';
    };

    users = mkOption {
      type = types.listOf types.str;
      default = [ ];
      example = [ "demo" ];
      description = ''
        A list of users whose browser profiles should be sync'd to tmpfs.
      '';
    };

    browsers = mkOption {
      type = types.listOf types.str;
      default = [ ];
      example = [ "chromium" "firefox" ];
      description = ''
        A list of browsers to sync. Available choices are:

        chromium chromium-dev conkeror.mozdev.org epiphany firefox
        firefox-trunk google-chrome google-chrome-beta google-chrome-unstable
        heftig-aurora icecat luakit midori opera opera-developer opera-beta
        qupzilla palemoon rekonq seamonkey

        An empty list will enable all browsers.
      '';
    };

    resyncTimer = mkOption {
      type = types.str;
      default = "1h";
      example = "1h 30min";
      description = ''
        The amount of time to wait before syncing browser profiles back to the
        disk.

        Takes a systemd.unit time span. The time unit defaults to seconds if
        omitted.
      '';
    };

    volatile = mkOption {
      type = types.str;
      default = "/run/psd-profiles";
      description = ''
        The directory where browser profiles should reside(this should be
        mounted as a tmpfs). Do not include a trailing backslash.
      '';
    };

    daemonFile = mkOption {
      type = types.str;
      default = "/run/psd";
      description = ''
        Where the pid and backup configuration files will be stored.
      '';
    };

  };

  config = mkIf config.services.psd.enable {

    systemd = {

      services = {

        psd = {
          description = "Profile Sync daemon";
          wants = [ "psd-resync.service" "local-fs.target" ];
          wantedBy = [ "multi-user.target" ];
          preStart = "mkdir -p ${config.services.psd.volatile}";

          path = [
            pkgs.glibc
            pkgs.rsync
            pkgs.gawk
          ];

          unitConfig = {
            RequiresMountsFor = [ "/home/" ];
          };

          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = "yes";
            ExecStart = "${pkgs.profile-sync-daemon}/bin/profile-sync-daemon sync";
            ExecStop = "${pkgs.profile-sync-daemon}/bin/profile-sync-daemon unsync";
          };
        };

        psd-resync = {
          description = "Timed profile resync";
          after = [ "psd.service" ];
          wants = [ "psd-resync.timer" ];
          partOf = [ "psd.service" ];

          path = [
            pkgs.glibc
            pkgs.rsync
            pkgs.gawk
          ];

          serviceConfig = {
            Type = "oneshot";
            ExecStart = "${pkgs.profile-sync-daemon}/bin/profile-sync-daemon resync";
          };
        };

      };

      timers.psd-resync = {
        description = "Timer for profile sync daemon - ${config.services.psd.resyncTimer}";
        partOf = [ "psd-resync.service" "psd.service" ];

        timerConfig = {
          OnUnitActiveSec = "${config.services.psd.resyncTimer}";
        };
      };

    };

    environment.etc."psd.conf".text = configFile;

  };
}
