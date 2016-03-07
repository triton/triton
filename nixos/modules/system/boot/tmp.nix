{ config, lib, ... }:

with lib;

{

  ###### interface

  options = {

    boot.tmpOnTmpfs = mkOption {
      type = types.bool;
      default = false;
      description = ''
         Whether to mount a tmpfs on <filename>/tmp</filename> during boot.
      '';
    };

  };

  ###### implementation

  config = {

    systemd.additionalUpstreamSystemUnits = optional config.boot.tmpOnTmpfs "tmp.mount";

  };

}
