{ stdenv
, fetchurl
, lib
, makeWrapper

, adwaita-icon-theme
, alsa-lib
, atk
, cairo
, cups
, dbus
, expat
, fontconfig
, freetype
, gconf
, gdk-pixbuf
, glib
, gnome-themes-standard
, gtk_2
, libnotify
, libx11
, libxcb
, libxcomposite
, libxcursor
, libxdamage
, libxext
, libxfixes
, libxi
, libxrandr
, libxrender
, libxscrnsaver
, libxtst
, llvm
, nspr
, nss
, pango
, pulseaudio_lib
, shared-mime-info
, systemd_lib

, channel ? "stable"
}:

let
  inherit (lib)
    makeSearchPath;

  nameext =
    if channel == "canary" then
      "-canary"
    else if channel == "ptb" then
      "-ptb"
    else
      "";
  nameexe =
    if channel == "canary" then
      "Canary"
    else if channel == "ptb" then
      "PTB"
    else
      "";

  sources = {
    "stable" = {
      version = "0.0.5";
      sha256 = "2f4464bcea532673ca7b314dc2a1b7966f5d175e535a0254753f778dc559ef18";
    };
    "ptb" = {
      version = "0.0.9";
      sha256 = "372d6f75203626370218c97c21519b779e5af334177cafa65a5655e357c77520";
    };
    "canary" = {
      version = "0.0.45";
      sha256 = "fa9d48626334434f3f306c42c694d1f22ca8ee0668fc0fddc42fe85f475d0a4a";
    };
  };
  source = sources."${channel}";
in
stdenv.mkDerivation rec {
  name = "discord${nameext}-${source.version}";

  src = fetchurl {
    url = "https://dl${nameext}.discordapp.net/apps/linux/${source.version}/"
      + "${name}.tar.gz";
    inherit (source) sha256;
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  buildInputs = [
    adwaita-icon-theme
    gnome-themes-standard
  ];

  libPath = makeSearchPath "lib" [
    alsa-lib
    atk
    cairo
    cups
    dbus
    expat
    fontconfig
    freetype
    gconf
    gdk-pixbuf
    glib
    gtk_2
    libnotify
    libx11
    libxcb
    libxcomposite
    libxcursor
    libxdamage
    libxext
    libxfixes
    libxi
    libxrandr
    libxrender
    libxscrnsaver
    libxtst
    llvm  # libc++
    nspr
    nss
    pango
    pulseaudio_lib
    stdenv.cc.cc
    systemd_lib
  ];

  installPhase = ''
    install -D -m 644 -v discord.png $out/share/pixmaps/discord.png

    install -D -m 644 -v discord${nameext}.desktop \
     $out/share/applications/discord${nameext}.desktop

    mkdir -pv $out/{bin,share/{discord,pixmaps}}
    mv * $out/share/discord

    patchelf \
      --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      --set-rpath "$out/share/discord:${libPath}"                                   \
      $out/share/discord/Discord${nameexe}

    wrapProgram $out/share/discord/Discord${nameexe} \
      --set 'GDK_PIXBUF_MODULE_FILE' '${gdk-pixbuf.loaders.cache}' \
      --prefix 'LD_LIBRARY_PATH' : "${libPath}" \
      --prefix 'XDG_DATA_DIRS' : "$XDG_ICON_DIRS" \
      --prefix 'XDG_DATA_DIRS' : "${shared-mime-info}/share" \
      --run "$DEFAULT_GTK2_RC_FILES"

    ln -sv $out/share/discord/Discord${nameexe} \
      $out/bin/discord${nameext}
  '';

  meta = with lib; {
    description = "All-in-one voice and text chat";
    homepage = https://discordapp.com/;
    license = licenses.unfree;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
