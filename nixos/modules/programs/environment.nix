# This module defines a standard configuration for NixOS global environment.

# Most of the stuff here should probably be moved elsewhere sometime.

{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.environment;

in

{

  config = {

    environment.variables =
      { LOCATE_PATH = "/var/cache/locatedb";
        PAGER = mkDefault "less -R";
        EDITOR = mkDefault "nano";
      };

    environment.profiles =
      [ "$HOME/.nix-profile"
        "/run/current-system/sw"
      ];

    # TODO: move most of these elsewhere
    environment.profileRelativeEnvVars =
      { PATH = [ "/bin" "/sbin" ];
        INFOPATH = [ "/info" "/share/info" ];
        PKG_CONFIG_PATH = [ "/lib/pkgconfig" ];
        TERMINFO_DIRS = [ "/share/terminfo" ];
        PERL5LIB = [ "/${pkgs.perlPackages.perl.libPrefix}" ];
        KDEDIRS = [ "" ];
        STRIGI_PLUGIN_PATH = [ "/lib/strigi/" ];
        QT_PLUGIN_PATH = [ "/lib/qt4/plugins" "/lib/kde4/plugins" ];
        QTWEBKIT_PLUGIN_PATH = [ "/lib/mozilla/plugins/" ];
        GTK_PATH = [ "/lib/gtk-2.0" "/lib/gtk-3.0" ];
        XDG_CONFIG_DIRS = [ "/etc/xdg" ];
        XDG_DATA_DIRS = [ "/share" ];
        MOZ_PLUGIN_PATH = [ "/lib/mozilla/plugins" ];
        LIBEXEC_PATH = [ "/lib/libexec" ];
      };

    environment.extraInit =
      ''
         # reset TERM with new TERMINFO available (if any)
         export TERM=$TERM

         unset ASPELL_CONF
         for i in ${concatStringsSep " " (reverseList cfg.profiles)} ; do
           if [ -d "$i/lib/aspell" ]; then
             export ASPELL_CONF="dict-dir $i/lib/aspell"
           fi
         done

         export NIX_USER_PROFILE_DIR="/nix/var/nix/profiles/per-user/$USER"
         export NIX_PROFILES="${concatStringsSep " " (reverseList cfg.profiles)}"
      '';

  };

}
