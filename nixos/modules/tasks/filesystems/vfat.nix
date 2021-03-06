{ config, lib, pkgs, ... }:

with lib;

let

  inInitrd = any (fs: fs == "vfat") config.boot.initrd.supportedFilesystems;

in

{
  config = mkIf (any (fs: fs == "vfat") config.boot.supportedFilesystems) {

    system.fsPackages = [
      pkgs.dosfstools
    ];

    boot.initrd.kernelModules = mkIf inInitrd [
      "nls_cp437"
      "nls_iso8859-1"
      "vfat"
    ];

    boot.initrd.extraUtilsCommands = mkIf inInitrd ''
      copy_bin_and_libs ${pkgs.dosfstools}/bin/fsck.fat
      ln -sv fsck.fat $out/bin/fsck.vfat
    '';
  };
}
