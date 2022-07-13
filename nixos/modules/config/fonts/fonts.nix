{ config, lib, pkgs, ... }:

with lib;

{

  options = {

    fonts = {

      # TODO: find another name for it.
      fonts = mkOption {
        type = types.listOf types.path;
        example = literalExample "[ pkgs.dejavu-fonts ]";
        description = "List of primary font paths.";
      };

    };

  };

  config = {

    fonts.fonts =
      [ pkgs.xorg.fontbhttf
        pkgs.xorg.fontbhlucidatypewriter100dpi
        pkgs.xorg.fontbhlucidatypewriter75dpi
        pkgs.dejavu-fonts
        pkgs.freefont_ttf
        pkgs.liberation-fonts
        pkgs.xorg.fontbh100dpi
        pkgs.xorg.fontmiscmisc
        pkgs.xorg.fontcursormisc
      ];

  };

}
