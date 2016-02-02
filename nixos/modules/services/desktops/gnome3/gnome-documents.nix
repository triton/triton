{ config, pkgs, lib, ... }:

with {
  inherit (lib)
    mkIf
    mkOption
    types;
};

{

  options = {

    services.gnome-documents = {

      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable GNOME Documents services, a document
          manager application for GNOME.
        '';
      };

    };

  };

  config = mkIf config.services.gnome-documents.enable {

    environment.systemPackages = [
      pkgs.gnome-documents
    ];

    services.dbus.packages = [
      pkgs.gnome-documents
    ];

    services.gnome-online-accounts.enable = true;

    services.gnome-online-miners.enable = true;

  };

}
