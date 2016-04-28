{ config, lib, pkgs, ... }:

with {
  inherit (lib)
    mkIf
    mkOption
    types;
};

{

  options = {

    services.nautilus = {

      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable nautilus service.
        '';
      };

    };

  };

  config = mkIf config.services.nautilus.enable {

    environment.systemPackages = [
      pkgs.nautilus
    ];

    environment.variables = {
      NAUTILUS_EXTENSION_DIR = "${config.system.path}/lib/nautilus/extensions-3.0/";
    };

  };

}
