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
      version = "0.0.4";
      sha256 = "8b62e49088d3bf525ab07ba6a64ec3f1c8c7c252a9c13178d060efb0674e9caa";
    };
    "ptb" = {
      version = "0.0.7";
      sha256 = "c0636961f4b3bf484c81f283873572cf526ad36fd6ff423c31bdfea010211d50";
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
