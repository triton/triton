{ config, lib, pkgs, ... }:

with lib;

let

  inInitrd = any (fs: fs == "bcache") config.boot.initrd.supportedFilesystems;

in

{
  config = mkIf (any (fs: fs == "bcache") config.boot.supportedFilesystems) {

    assertions = [
      {
        assertion = config.boot.kernelPackages.kernel.features.bcachefs or false;
        message = "You must have a kernel that supports bcachefs";
      }
    ];

    system.fsPackages = [ pkgs.bcache-tools_dev ];

    boot.initrd.kernelModules = mkIf inInitrd [ "bcache" ];

  };
}
