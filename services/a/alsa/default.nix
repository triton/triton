# ALSA sound support.
{ config, lib, pkgs, ... }:

with lib;

{

  ###### interface

  options = {

    sound = {

      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable ALSA sound.
        '';
      };

      enableMediaKeys = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable volume and capture control with keyboard media keys.

          Enabling this will turn on <option>services.actkbd</option>.
        '';
      };

      extraConfig = mkOption {
        type = types.lines;
        default = "";
        example = ''
          defaults.pcm.!card 3
        '';
        description = ''
          Set addition configuration for system-wide alsa.
        '';
      };

    };

  };


  ###### implementation

  config = mkIf config.sound.enable {

    environment.systemPackages = [ pkgs.alsa-utils ];

    environment.etc = mkIf (config.sound.extraConfig != "")
      [
        { source = pkgs.writeText "asound.conf" config.sound.extraConfig;
          target = "asound.conf";
        }
      ];

    # ALSA provides a udev rule for restoring volume settings.
    services.udev.packages = [ pkgs.alsa-utils ];

    systemd.services."alsa-store" =
      { description = "Store Sound Card State";
        wantedBy = [ "multi-user.target" ];
        unitConfig.RequiresMountsFor = "/var/lib/alsa";
        unitConfig.ConditionVirtualization = "!systemd-nspawn";
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = "${pkgs.coreutils}/bin/mkdir -p /var/lib/alsa";
          ExecStop = "${pkgs.alsa-utils}/sbin/alsactl store --ignore";
        };
      };

    services.actkbd = mkIf config.sound.enableMediaKeys {
      enable = true;
      bindings = [
        # "Mute" media key
        { keys = [ 113 ];
          events = [ "key" ];
          command = "${pkgs.alsa-utils}/bin/amixer -q set Master toggle"; }

        # "Lower Volume" media key
        { keys = [ 114 ];
          events = [ "key" "rep" ];
          command = "${pkgs.alsa-utils}/bin/amixer -q set Master 1- unmute"; }

        # "Raise Volume" media key
        { keys = [ 115 ];
          events = [ "key" "rep" ];
          command = "${pkgs.alsa-utils}/bin/amixer -q set Master 1+ unmute"; }

        # "Mic Mute" media key
        { keys = [ 190 ];
          events = [ "key" ];
          command = "${pkgs.alsa-utils}/bin/amixer -q set Capture toggle"; }
      ];
    };

  };

}
