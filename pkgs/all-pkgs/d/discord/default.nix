{ stdenv
, fetchurl
, lib
, makeWrapper

, adwaita-icon-theme
, alsa-lib
, at-spi2-atk
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
, gtk_3
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
, util-linux_lib

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
      version = "0.0.8";
      sha256 = "d98418539bdd3fd908d7bd594697bcebfa33b24ed422be8096542d525435e8dc";
    };
    "ptb" = {
      version = "0.0.13";
      sha256 = "ee39b9910dede11a4cebab06ce4221bf4d79a78e46b7e7da5131a3897707123b";
    };
    "canary" = {
      version = "0.0.71";
      sha256 = "8f2a88ccc16ea017323ac9e2e402c2e85ee8735206f0f75c53bf1aba7786f00e";
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
    at-spi2-atk
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
    gtk_3
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
    util-linux_lib
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

    chmod 755 $out/share/discord/Discord${nameexe}
    wrapProgram $out/share/discord/Discord${nameexe} \
      --set 'GDK_PIXBUF_MODULE_FILE' '${gdk-pixbuf.loaders.cache}' \
      --prefix 'LD_LIBRARY_PATH' : "${libPath}" \
      --prefix 'XDG_DATA_DIRS' : "$XDG_ICON_DIRS" \
      --prefix 'XDG_DATA_DIRS' : "${shared-mime-info}/share"

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
