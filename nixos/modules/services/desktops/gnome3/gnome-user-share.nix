{ config, pkgs, lib, ... }:

with {
  inherit (lib)
    mkIf
    mkOption
    types;
};

{

  options = {

    services.gnome-user-share = {

      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable GNOME User Share, a service that exports the
          contents of the Public folder in your home directory on the local network.
        '';
      };
    };


  };

  config = mkIf config.services.gnome-user-share.enable {

    environment.systemPackages = [
      pkgs.gnome-user-share
    ];

    services.xserver.displayManager.sessionCommands =
    /* Don't let gnome-control-center depend upon gnome-user-share */ ''
      export XDG_DATA_DIRS=$XDG_DATA_DIRS''${XDG_DATA_DIRS:+:}${pkgs.gnome-user-share}/share/gsettings-schemas/${pkgs.gnome-user-share.name}
    '';

  };

}
