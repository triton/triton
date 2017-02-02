{ config, lib, pkgs, ... }:

with pkgs;
with lib;

let

  cfg = config.hardware.pulseaudio;

  systemWide = cfg.enable && cfg.systemWide;
  nonSystemWide = cfg.enable && !cfg.systemWide;

  # Forces 32bit pulseaudio and alsaPlugins to be built/supported for apps
  # using 32bit alsa on 64bit linux.
  enable32BitAlsaPlugins = cfg.support32Bit && pkgs.pkgs_32.alsa-lib != null && pkgs.pkgs_32.pulseaudio_lib != null;

  ids = config.ids;

  uid = ids.uids.pulseaudio;
  gid = ids.gids.pulseaudio;

  stateDir = "/var/run/pulse";

  # Create pulse/client.conf even if PulseAudio is disabled so
  # that we can disable the autospawn feature in programs that
  # are built with PulseAudio support (like KDE).
  clientConf = writeText "client.conf" ''
    autospawn=${if nonSystemWide then "yes" else "no"}
    ${optionalString nonSystemWide "daemon-binary=${cfg.package}/bin/pulseaudio"}
  '';

  daemonConf = writeText "daemon.conf" ''
    flat-volumes=no
  '';

  # Write an /etc/asound.conf that causes all ALSA applications to
  # be re-routed to the PulseAudio server through ALSA's Pulse
  # plugin.
  alsaConf = writeText "asound.conf" (''
    # Non-stereo layouts have their own configs and need to be individually
    # overridden to force routing through pulseaudio.
    # See alsa-lib/src/conf/pcm/ for default configs.
    pcm.!surround71 {
      slave.pcm "default"
    }
    pcm.!surround51 {
      slave.pcm "default"
    }
    pcm.!surround50 {
      slave.pcm "default"
    }
    pcm.!surround41 {
      slave.pcm "default"
    }
    pcm.!surround40 {
      slave.pcm "default"
    }
    pcm.!surround21 {
      slave.pcm "default"
    }
    pcm.!center_lfe {
      slave.pcm "default"
    }
    pcm.!front {
      slave.pcm "default"
    }
    pcm.!side {
      slave.pcm "default"
    }
    pcm.!rear {
      slave.pcm "default"
    }
    pcm.!modem {
      slave.pcm "default"
    }
    pcm.!phoneline {
      slave.pcm "default"
    }
    pcm.!iec958 {
      slave.pcm "default"
    }
    pcm.!hdmi {
      slave.pcm "default"
    }
    pcm.!dsnoop {
      slave.pcm "default"
    }
    pcm.!dpl {
      slave.pcm "default"
    }
    pcm.!dpl2 {
      slave.pcm "default"
    }
    pcm.!dmix {
      slave.pcm "default"
    }
    pcm_type.pulse {
      libs.native = ${pkgs.alsa-plugins}/lib/alsa-lib/libasound_module_pcm_pulse.so ;
      ${lib.optionalString enable32BitAlsaPlugins
     "libs.32Bit = ${pkgs.pkgs_32.alsa-plugins}/lib/alsa-lib/libasound_module_pcm_pulse.so ;"}
    }
    pcm.!default {
      type pulse
      hint.description "Default Audio Device (via PulseAudio)"
    }
    ctl_type.pulse {
      libs.native = ${alsa-plugins}/lib/alsa-lib/libasound_module_ctl_pulse.so ;
      ${lib.optionalString enable32BitAlsaPlugins
     "libs.32Bit = ${pkgs.pkgs_32.alsa-plugins}/lib/alsa-lib/libasound_module_ctl_pulse.so ;"}
    }
    ctl.!default {
      type pulse
    }
  '');

in {

  options = {

    hardware.pulseaudio = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable the PulseAudio sound server.
        '';
      };

      systemWide = mkOption {
        type = types.bool;
        default = false;
        description = ''
          If false, a PulseAudio server is launched automatically for
          each user that tries to use the sound system. The server runs
          with user privileges. This is the recommended and most secure
          way to use PulseAudio. If true, one system-wide PulseAudio
          server is launched on boot, running as the user "pulse".
          Please read the PulseAudio documentation for more details.
        '';
      };

      support32Bit = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to include the 32-bit pulseaudio libraries in the systemn or not.
          This is only useful on 64-bit systems and currently limited to x86_64-linux.
        '';
      };

      configFile = mkOption {
        type = types.path;
        description = ''
          The path to the configuration the PulseAudio server
          should use. By default, the "default.pa" configuration
          from the PulseAudio distribution is used.
        '';
      };

      package = mkOption {
        type = types.package;
        default = pulseaudio_full;
        defaultText = "pkgs.pulseaudio_full";
        example = literalExample "pkgs.pulseaudio_full";
        description = ''
          The PulseAudio derivation to use.  This can be used to disable
          features (such as JACK support, Bluetooth) that are enabled in the
          pulseaudio_full package in Nixpkgs.
        '';
      };

      daemon = {
        logLevel = mkOption {
          type = types.str;
          default = "notice";
          description = ''
            The log level that the system-wide pulseaudio daemon should use,
            if activated.
          '';
        };
      };
    };

  };


  config = mkMerge [
    {
      environment.etc = [
        {
          target = "pulse/client.conf";
          source = clientConf;
        }
        {
          target = "pulse/daemon.conf";
          source = daemonConf;
        }
      ];

      hardware.pulseaudio.configFile = mkDefault "${cfg.package}/etc/pulse/default.pa";
    }

    (mkIf cfg.enable {
      environment.systemPackages = [ cfg.package ];

      environment.etc = singleton {
        target = "asound.conf";
        source = alsaConf;
      };

      # Allow PulseAudio to get realtime priority using rtkit.
      security.rtkit.enable = true;
    })

    (mkIf nonSystemWide {
      environment.etc = singleton {
        target = "pulse/default.pa";
        source = cfg.configFile;
      };

      systemd.user = {
        services.pulseaudio = {
          description = "PulseAudio Server";
          # NixOS doesn't support "Also" so we bring it in manually
          wantedBy = [ "default.target" ];
          serviceConfig = {
            Type = "notify";
            ExecStart = "${cfg.package}/bin/pulseaudio --daemonize=no";
            Restart = "on-failure";
          };
        };

        sockets.pulseaudio = {
          description = "PulseAudio Socket";
          wantedBy = [ "sockets.target" ];
          socketConfig = {
            Priority = 6;
            Backlog = 5;
            ListenStream = "%t/pulse/native";
          };
        };
      };
    })

    (mkIf systemWide {
      users.extraUsers.pulse = {
        # For some reason, PulseAudio wants UID == GID.
        uid = assert uid == gid; uid;
        group = "pulse";
        extraGroups = [ "audio" ];
        description = "PulseAudio system service user";
        home = stateDir;
        createHome = true;
      };

      users.extraGroups.pulse.gid = gid;

      systemd.services.pulseaudio = {
        description = "PulseAudio System-Wide Server";
        wantedBy = [ "sound.target" ];
        before = [ "sound.target" ];
        environment.PULSE_RUNTIME_PATH = stateDir;
        serviceConfig = {
          Type = "notify";
          ExecStart = "${cfg.package}/bin/pulseaudio --daemonize=no --log-level=${cfg.daemon.logLevel} --system -n --file=${cfg.configFile}";
          Restart = "on-failure";
        };
      };
    })
  ];

}
