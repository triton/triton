{ config, lib, pkgs, ... }:

let
  cfgFile = pkgs.writeText "reader.conf" "";

  polkitRules = "polkit-1/rules.d/50-pcscd.rules";

  pcscPolkit = pkgs.stdenv.mkDerivation {
    name = "polkit-${pkgs.pcsc-lite.name}";

    buildCommand = ''
      mkdir -p "$out/share"
      ln -sv "${pkgs.pcsc-lite}/share/polkit-1" "$out/share/polkit-1"
    '';
  };
in

with lib;

{

  ###### interface

  options = {

    services.pcscd = {

      enable = mkOption {
        default = false;
        description = "Whether to enable the PCSC-Lite daemon.";
      };

      allowedUsers = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = ''
          A list of users who can access pcsclite backed devices.
        '';
      };

      allowedGroups = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = ''
          A list of groups who can access pcsclite backed devices.
        '';
      };
    };

  };


  ###### implementation

  config = mkIf config.services.pcscd.enable {

    environment.systemPackages = [
      pcscPolkit
    ];

    security.polkit.enable = true;

    security.polkit.extraConfig = ''
      polkit.addRule(function(action, subject) {
        if (action.id != "org.debian.pcsc-lite.access_card" &&
            action.id != "org.debian.pcsc-lite.access_pcsc") {
          return;
        }
    '' + flip concatMapStrings config.services.pcscd.allowedUsers (n: ''
        if (subject.user == "${n}") {
          return polkit.Result.YES;
        }
    '') + flip concatMapStrings config.services.pcscd.allowedGroups (n: ''
        for each (var group in subject.groups) {
          if (group == "${n}") {
            return polkit.Result.YES;
          }
        }
    '') + ''
      });
    '';

    systemd.sockets.pcscd = {
      description = "PCSC-Lite Socket";
      wantedBy = [ "sockets.target" ];
      before = [ "multi-user.target" ];
      socketConfig.ListenStream = "/run/pcscd/pcscd.comm";
    };

    systemd.services.pcscd = {
      description = "PCSC-Lite daemon";
      preStart = ''
        mkdir -p /var/lib/pcsc
        rm -Rf /var/lib/pcsc/drivers
        ln -s ${pkgs.ccid}/pcsc/drivers /var/lib/pcsc/
      '';
      serviceConfig = {
        Type = "forking";
        ExecStart = "${pkgs.pcsc-lite}/sbin/pcscd --auto-exit -c ${cfgFile}";
        ExecReload = "${pkgs.pcsc-lite}/sbin/pcscd --hotplug";
      };
    };

  };

}
