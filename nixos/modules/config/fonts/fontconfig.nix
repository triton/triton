{ config, lib, pkgs, ... }:

let
  inherit (lib)
    concatStringsSep
    mkIf
    mkOption
    optionalString
    types;
in
{
  options = {
    fontconfig = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          If enabled, a Fontconfig configuration file will be built
          pointing to a set of default fonts.  If you care about
          running X11 applications or any other program that uses
          Fontconfig, you should turn this option on.
        '';
      };

      antialias = mkOption {
        type = types.bool;
        default = true;
        description = "Enable font antialiasing.";
      };

      dpi = mkOption {
        type = types.int;
        default = 0;
        description = ''
          Force DPI setting. Setting to <literal>0</literal> disables DPI
          forcing; the DPI detected for the display will be used.
        '';
      };

      hinting = mkOption {
        type = types.bool;
        default = true;
        description = "Enable TrueType hinting.";
      };

      autohint = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Enable the autohinter, which provides hinting for otherwise
          un-hinted fonts. The results are usually lower quality than
          correctly-hinted fonts.
        '';
      };

      hintstyle = mkOption {
        type = types.enum ["none" "slight" "medium" "full"];
        default = "slight";
        description = ''
          TrueType hinting style, one of <literal>none</literal>,
          <literal>slight</literal>, <literal>medium</literal>, or
          <literal>full</literal>.
        '';
      };

      rgba = mkOption {
        type = types.enum ["rgb" "bgr" "vrgb" "vbgr" "none"];
        default = "rgb";
        description = ''
          Subpixel order, one of <literal>none</literal>,
          <literal>rgb</literal>, <literal>bgr</literal>,
          <literal>vrgb</literal>, or <literal>vbgr</literal>.
        '';
      };

      lcdfilter = mkOption {
        type = types.enum ["none" "default" "light" "legacy"];
        default = "default";
        description = ''
          FreeType LCD filter, one of <literal>none</literal>,
          <literal>default</literal>, <literal>light</literal>, or
          <literal>legacy</literal>.
        '';
      };

      defaultFonts = {
        monospace = mkOption {
          type = types.listOf types.str;
          default = ["DejaVu Sans Mono"];
          description = ''
            System-wide default monospace font(s). Multiple fonts may be
            listed in case multiple languages must be supported.
          '';
        };

        sansSerif = mkOption {
          type = types.listOf types.str;
          default = ["DejaVu Sans"];
          description = ''
            System-wide default sans serif font(s). Multiple fonts may be
            listed in case multiple languages must be supported.
          '';
        };

        serif = mkOption {
          type = types.listOf types.str;
          default = ["DejaVu Serif"];
          description = ''
            System-wide default serif font(s). Multiple fonts may be listed
            in case multiple languages must be supported.
          '';
        };
      };

      includeUserConf = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Include the user configuration from
          <filename>~/.config/fontconfig/fonts.conf</filename> or
          <filename>~/.config/fontconfig/conf.d</filename>.
        '';
      };

      cache32Bit = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Generate system fonts cache for 32-bit applications.
        '';
      };
    };
  };

  config =
    let
      fontconfig = config.fontconfig;
      fcBool = x: "<bool>" + (if x then "true" else "false") + "</bool>";
      renderConf = ''
        <?xml version='1.0'?>
        <!DOCTYPE fontconfig SYSTEM 'fonts.dtd'>
        <fontconfig>

          <!-- Default rendering settings -->
          <match target="font">
            <edit mode="assign" name="hinting">
              ${fcBool fontconfig.hinting}
            </edit>
          </match>
          <match target="font">
            <edit mode="assign" name="autohint">
              ${fcBool fontconfig.autohint}
            </edit>
          </match>
          <match target="font">
            <edit mode="assign" name="hintstyle">
              <const>hint${fontconfig.hintstyle}</const>
            </edit>
          </match>
          <match target="font">
            <edit mode="assign" name="antialias">
              ${fcBool fontconfig.antialias}
            </edit>
          </match>
          <match target="font">
            <edit mode="assign" name="rgba">
              <const>${fontconfig.rgba}</const>
            </edit>
          </match>
          <match target="font">
            <edit mode="assign" name="lcdfilter">
              <const>lcd${fontconfig.lcdfilter}</const>
            </edit>
          </match>

          ${optionalString (fontconfig.dpi != 0) ''
          <match target="pattern">
            <edit name="dpi" mode="assign">
              <double>${toString fontconfig.dpi}</double>
            </edit>
          </match>
          ''}

        </fontconfig>
      '';
      genericAliasConf = ''
        <?xml version='1.0'?>
        <!DOCTYPE fontconfig SYSTEM 'fonts.dtd'>
        <fontconfig>

          <!-- Default fonts -->
          ${optionalString (fontconfig.defaultFonts.sansSerif != []) ''
          <alias>
            <family>sans-serif</family>
            <prefer>
              ${concatStringsSep "\n"
                (map (font: "<family>${font}</family>")
                  fontconfig.defaultFonts.sansSerif)}
            </prefer>
          </alias>
          ''}
          ${optionalString (fontconfig.defaultFonts.serif != []) ''
          <alias>
            <family>serif</family>
            <prefer>
              ${concatStringsSep "\n"
                (map (font: "<family>${font}</family>")
                  fontconfig.defaultFonts.serif)}
            </prefer>
          </alias>
          ''}
          ${optionalString (fontconfig.defaultFonts.monospace != []) ''
          <alias>
            <family>monospace</family>
            <prefer>
              ${concatStringsSep "\n"
                (map (font: "<family>${font}</family>")
                  fontconfig.defaultFonts.monospace)}
            </prefer>
          </alias>
          ''}

        </fontconfig>
      '';
    in
    mkIf fontconfig.enable {
      assertions = [
        {
          assertion = !fontconfig.cache32Bit;
          message = "We don't support caching 32bit yet";
        }
      ];

      # Versioned fontconfig > 2.10. Take shared fonts.conf from fontconfig.
      # Otherwise specify only font directories.
      environment.etc."fonts/${pkgs.fontconfig.configVersion}/fonts.conf".source =
        "${pkgs.fontconfig}/etc/fonts/fonts.conf";

      environment.etc."fonts/${pkgs.fontconfig.configVersion}/conf.d/00-nixos.conf".text =
        let
          cache = fontconfig: pkgs.makeFontsCache {
            inherit fontconfig;
            fontDirectories = config.fonts.fonts;
          };
        in ''
          <?xml version='1.0'?>
          <!DOCTYPE fontconfig SYSTEM 'fonts.dtd'>
          <fontconfig>
            <!-- Font directories -->
            ${concatStringsSep "\n" (map (font: "<dir>${font}</dir>") config.fonts.fonts)}
            <!-- Pre-generated font caches -->
            <cachedir>${cache pkgs.fontconfig}</cachedir>
          </fontconfig>
        '';

      environment.etc."fonts/${pkgs.fontconfig.configVersion}/conf.d/10-nixos-rendering.conf".text = renderConf;
      environment.etc."fonts/${pkgs.fontconfig.configVersion}/conf.d/60-nixos-generic-alias.conf".text = genericAliasConf;

      environment.etc."fonts/${pkgs.fontconfig.configVersion}/conf.d/99-user.conf" = {
        enable = fontconfig.includeUserConf;
        text = ''
          <?xml version="1.0"?>
          <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
          <fontconfig>
            <include ignore_missing="yes" prefix="xdg">fontconfig/conf.d</include>
            <include ignore_missing="yes" prefix="xdg">fontconfig/fonts.conf</include>
          </fontconfig>
        '';
      };

      environment.systemPackages = [ pkgs.fontconfig ];
    };
}
