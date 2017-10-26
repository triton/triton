{ stdenv
, fetchurl
, gettext
, intltool
, makeWrapper

, adwaita-icon-theme
, dconf
, gconf
, gdk-pixbuf
, glib
, gnome-desktop
, gnome-settings-daemon
, gsettings-desktop-schemas
, gtk
, json-glib
, libepoxy
, mutter
, opengl-dummy
, systemd_lib
, upower
, xorg

, channel
}:

# FIXME: fix Xsync support

let
  inherit (stdenv.lib)
    boolEn
    boolWt
    optionals;

  source = (import ./sources.nix { })."${channel}";
in
stdenv.mkDerivation rec {
  name = "gnome-session-${source.version}";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-session/${channel}/${name}.tar.xz";
    hashOutput = false;
    inherit (source) sha256;
  };

  nativeBuildInputs = [
    gettext
    intltool
    makeWrapper
  ];

  buildInputs = [
    adwaita-icon-theme
    dconf
    gconf
    gdk-pixbuf
    glib
    gnome-desktop
    gnome-settings-daemon
    gsettings-desktop-schemas
    gtk
    json-glib
    libepoxy
    mutter  # gschemas
    opengl-dummy
    systemd_lib
    upower
  ] ++ optionals (xorg != null) [
    xorg.libICE
    xorg.libSM
    xorg.libX11
    xorg.libXau
    xorg.libXcomposite
    xorg.libXext
    xorg.libXrender
    xorg.libXtst
    xorg.xtrans
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-compile-warnings"
    "--disable-iso-c"
    "--enable-deprecation-flags"
    "--enable-session-selector"
    # Support legacy gconf autostart
    "--${boolEn (gconf != null)}-gconf"
    "--${boolEn (systemd_lib != null)}-systemd"
    "--disable-consolekit"
    "--disable-docbook-docs"
    "--disable-man"
    "--enable-nls"
    "--enable-schemas-compile"
    "--enable-ipv6"
    "--${boolWt (xorg != null)}-xtrans"
  ];

  preFixup = ''
    wrapProgram $out/bin/gnome-session \
      --prefix 'PATH' : "${glib}/bin" \
      --prefix 'XDG_DATA_DIRS' : "$GSETTINGS_SCHEMAS_PATH"

    wrapProgram $out/libexec/gnome-session-binary \
      --set 'GSETTINGS_BACKEND' 'dconf' \
      --prefix 'GIO_EXTRA_MODULES' : "$GIO_EXTRA_MODULES" \
      --prefix 'GI_TYPELIB_PATH' : "$GI_TYPELIB_PATH" \
      --prefix 'PATH' : "${gnome-settings-daemon}/bin" \
      --prefix 'XDG_DATA_DIRS' : "$GSETTINGS_SCHEMAS_PATH" \
      --prefix 'XDG_DATA_DIRS' : "$out/share" \
      --prefix 'XDG_DATA_DIRS' : "$XDG_ICON_DIRS"
  '';

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Url = "https://download.gnome.org/sources/gnome-session/${channel}/"
        + "${name}.sha256sum";
      failEarly = true;
    };
  };

  meta = with stdenv.lib; {
    description = "Gnome session manager";
    homepage = https://git.gnome.org/browse/gnome-session;
    license = with licenses; [
      #fdl11
      gpl2
      lgpl2
    ];
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };

}
