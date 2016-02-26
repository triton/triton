{ stdenv
, makeDesktopItem
, makeWrapper
, config

## various stuff that can be plugged in
, gnash
, flashplayer
, hal-flash
, MPlayerPlugin
, gecko_mediaplayer
, xorg
, pulseaudio_lib
, libcanberra
, ffmpeg
, gstreamer
, gst-plugins-base
, gst-plugins-good
, gst-libav
#, jrePlugin
, icedtea_web
, trezor-bridge
, bluejeans
, djview4
, adobe-reader
, google_talk_plugin
, fribid
, gnome-shell
}:

with {
  inherit (stdenv.lib)
    attrByPath
    concatStrings
    concatStringsSep
    head
    intersperse
    optional
    optionals
    optionalString
    splitString
    substring
    toUpper;
};

## configurability of the wrapper itself
browser :
{
# name of the executable
browserName ? (head (splitString "-" browser.name))
, name ? (browserName + "-" + (builtins.parseDrvName browser.name).version)
# Formatted name of the browser
, desktopName ? (toUpper (substring 0 1 browserName) + substring 1 (-1) browserName)
, nameSuffix ? ""
, icon ? browserName
, libtrick ? true
}:

let
  cfg = attrByPath [ browserName ] {} config;
  enableAdobeFlash = cfg.enableAdobeFlash or false;
  enableGnash = cfg.enableGnash or false;
  jre = cfg.jre or false;
  icedtea = cfg.icedtea or false;
  plugins =
     assert !(enableGnash && enableAdobeFlash);
     assert !(jre && icedtea);
     ([ ]
      ++ optional enableGnash gnash
      ++ optional enableAdobeFlash flashplayer
      ++ optional (cfg.enableDjvu or false) (djview4)
      ++ optional (cfg.enableMPlayer or false) (MPlayerPlugin browser)
      ++ optional (cfg.enableGeckoMediaPlayer or false) gecko_mediaplayer
      #++ optional (jre && jrePlugin ? mozillaPlugin) jrePlugin
      ++ optional icedtea icedtea_web
      ++ optional (cfg.enableGoogleTalkPlugin or false) google_talk_plugin
      ++ optional (cfg.enableFriBIDPlugin or false) fribid
      ++ optional (cfg.enableGnomeExtensions or false) gnome-shell
      ++ optional (cfg.enableTrezor or false) trezor-bridge
      ++ optional (cfg.enableBluejeans or false) bluejeans
      ++ optional (cfg.enableAdobeReader or false) adobe-reader
     );
  libs = [
    ffmpeg
    gstreamer
    gst-plugins-base
  ] ++ optionals (cfg.enableQuakeLive or false) (with xorg; [
    stdenv.cc
    libX11
    libXxf86dga
    libXxf86vm
    libXext
    libXt
    alsa-lib
    zlib
  ]) ++ optionals (enableAdobeFlash && (cfg.enableAdobeFlashDRM or false)) [
    hal-flash
  ] ++ optionals (config.pulseaudio or false) [
    libpulseaudio
  ];
  gtk_modules = [
    libcanberra
  ];
in

stdenv.mkDerivation {
  inherit name;

  desktopItem = makeDesktopItem {
    name = browserName;
    exec = browserName + " %U";
    inherit icon;
    comment = "";
    desktopName = desktopName;
    genericName = "Web Browser";
    categories = "Application;Network;WebBrowser;";
    mimeType = concatStringsSep ";" [
      "text/html"
      "text/xml"
      "application/xhtml+xml"
      "application/vnd.mozilla.xul+xml"
      "x-scheme-handler/http"
      "x-scheme-handler/https"
      "x-scheme-handler/ftp"
    ];
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  buildInputs = [
    gst-plugins-base
    gst-plugins-good
    gst-libav
    gstreamer
  ];

  buildCommand = ''
    if [ ! -x "${browser}/bin/${browserName}" ] ; then
      echo "cannot find executable file \`${browser}/bin/${browserName}'"
      exit 1
    fi

    makeWrapper "${browser}/bin/${browserName}" \
      "$out/bin/${browserName}${nameSuffix}" \
      --suffix-each MOZ_PLUGIN_PATH ':' "$plugins" \
      --suffix-each LD_LIBRARY_PATH ':' "$libs" \
      --suffix-each GTK_PATH ':' "$gtk_modules" \
      --suffix-each LD_PRELOAD ':' "$(cat $(filterExisting $(addSuffix /extra-ld-preload $plugins)))" \
      --prefix GST_PLUGIN_PATH : "$GST_PLUGIN_PATH" \
      --prefix-contents PATH ':' "$(filterExisting $(addSuffix /extra-bin-path $plugins))" \
      --set MOZ_OBJDIR "$(ls -d "${browser}/lib/${browserName}"*)"

    ${optionalString libtrick
    ''
    libdirname="$(echo "${browser}/lib/${browserName}"*)"
    libdirbasename="$(basename "$libdirname")"
    mkdir -pv "$out/lib/$libdirbasename"
    ln -sv "$libdirname"/* "$out/lib/$libdirbasename"
    script_location="$(mktemp "$out/lib/$libdirbasename/${browserName}${nameSuffix}.XXXXXX")"
    mv -v "$out/bin/${browserName}${nameSuffix}" "$script_location"
    ln -sv "$script_location" "$out/bin/${browserName}${nameSuffix}"
    ''
    }

    if [ -e "${browser}/share/icons" ] ; then
      mkdir -p "$out/share"
      ln -sv "${browser}/share/icons" "$out/share/icons"
    else
      mkdir -pv "$out/share/icons/hicolor/128x128/apps"
      ln -sv \
        "$out/lib/$libdirbasename/browser/icons/mozicon128.png" \
        "$out/share/icons/hicolor/128x128/apps/${browserName}.png"
    fi

    mkdir -pv $out/share/applications
    cp -v $desktopItem/share/applications/* $out/share/applications

    # For manpages, in case the program supplies them
    mkdir -pv $out/nix-support
    echo ${browser} > $out/nix-support/propagated-user-env-packages
  '';

  preferLocalBuild = true;

  # Let each plugin tell us (through its `mozillaPlugin') attribute
  # where to find the plugin in its tree.
  plugins = map (x: x + x.mozillaPlugin) plugins;
  libs = map (x: x + "/lib") libs ++ map (x: x + "/lib64") libs;
  gtk_modules = map (x: x + x.gtkModule) gtk_modules;

  passthru = { unwrapped = browser; };

  meta = browser.meta // {
    description =
      browser.meta.description
      + " (with plugins: "
      + concatStrings (intersperse ", " (map (x: x.name) plugins))
      + ")";
    hydraPlatforms = [];
    priority = (browser.meta.priority or 0) - 1; # prefer wrapper over the package
  };
}
