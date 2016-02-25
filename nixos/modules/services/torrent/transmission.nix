{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.transmission;

  homeDir = "/var/lib/transmission";
  downloadDir = "${homeDir}/Downloads";
  incompleteDir = "${homeDir}/.incomplete";

  settingsDir = "${homeDir}/.config/transmission-daemon";
  settingsFile = pkgs.writeText "settings.json" (builtins.toJSON fullSettings);

  # Strings must be quoted, ints and bools must not (for settings.json).
  toOption = x:
    if x == true then "true"
    else if x == false then "false"
    else if isInt x then toString x
    else toString ''"${x}"'';

  # for users in group "transmission" to have access to torrents
  fullSettings = { download-dir = downloadDir; incomplete-dir = incompleteDir; } // cfg.settings // { umask = 2; };
in
{
  options = {
    services.transmission = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether or not to enable the headless Transmission BitTorrent daemon.

          Transmission daemon can be controlled via the RPC interface using
          transmission-remote or the WebUI (http://localhost:9091/ by default).

          Torrents are downloaded to ${downloadDir} by default and are
          accessible to users in the "transmission" group.
        '';
      };

      settings = mkOption {
        type = types.attrs;
        default =
          {
            download-dir = downloadDir;
            incomplete-dir = incompleteDir;
            incomplete-dir-enabled = true;
          };
        example =
          {
            download-dir = "/srv/torrents/";
            incomplete-dir = "/srv/torrents/.incomplete/";
            incomplete-dir-enabled = true;
            rpc-whitelist = "127.0.0.1,192.168.*.*";
          };
        description = ''
          Attribute set whos fields overwrites fields in settings.json (each
          time the service starts). String values must be quoted, integer and
          boolean values must not.

          See https://trac.transmissionbt.com/wiki/EditConfigFiles for
          documentation.
        '';
      };

      port = mkOption {
        type = types.int;
        default = 9091;
        description = "TCP port number to run the RPC/web interface.";
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.transmission = {
      description = "Transmission BitTorrent Service";
      after = [ "local-fs.target" "network.target" ];
      wantedBy = [ "multi-user.target" ];

      # 1) Only the "transmission" user and group have access to torrents.
      # 2) Optionally update/force specific fields into the configuration file.
      serviceConfig.ExecStartPre = ''
          ${pkgs.stdenv.shell} -c "mkdir -p ${homeDir} ${settingsDir} ${fullSettings.download-dir} ${fullSettings.incomplete-dir} && chmod 770 ${homeDir} ${settingsDir} ${fullSettings.download-dir} ${fullSettings.incomplete-dir} && rm -f ${settingsDir}/settings.json && cp -f ${settingsFile} ${settingsDir}/settings.json"
      '';
      serviceConfig.ExecStart = "${pkgs.transmission}/bin/transmission-daemon -f --port ${toString config.services.transmission.port}";
      serviceConfig.ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
      serviceConfig.User = "transmission";
      # NOTE: transmission has an internal umask that also must be set (in settings.json)
      serviceConfig.UMask = "0002";
    };

    # It's useful to have transmission in path, e.g. for remote control
    environment.systemPackages = [ pkgs.transmission ];

    users.extraGroups.transmission.gid = config.ids.gids.transmission;
    users.extraUsers.transmission = {
      group = "transmission";
      uid = config.ids.uids.transmission;
      description = "Transmission BitTorrent user";
      home = homeDir;
      createHome = true;
    };

  };

}
