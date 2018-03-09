{ stdenv
, fetchurl
, gettext
, intltool
, lib
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
, libice
, libsm
, libx11
, libxau
, libxcomposite
, libxext
, libxrender
, libxtst
, mutter
, opengl-dummy
, systemd_lib
, upower
, xtrans

, channel
}:

# FIXME: fix Xsync support

let
  inherit (lib)
    boolEn
    boolWt
    optionals;

  sources = {
    "3.26" = {
      version = "3.26.1";
      sha256 = "d9414b368db982d3837ca106e64019f18e6cdd5b13965bea6c7d02ddf5103708";
    };
  };
  source = sources."${channel}";
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
    libice
    libsm
    libx11
    libxau
    libxcomposite
    libxext
    libxrender
    libxtst
    mutter  # gschemas
    opengl-dummy
    systemd_lib
    upower
    xtrans
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
    "--disable-schemas-compile"
    "--enable-ipv6"
    "--${boolWt (xtrans != null)}-xtrans"
  ];

  preFixup = ''
    for prog in $out/bin/*; do
      wrapProgram $prog \
        --set 'GSETTINGS_BACKEND' 'dconf' \
        --prefix 'GIO_EXTRA_MODULES' : "$GIO_EXTRA_MODULES" \
        --prefix 'PATH' : "${glib}/bin" \
        --prefix 'PATH' : "$out/bin" \
        --prefix 'XDG_DATA_DIRS' : "$GSETTINGS_SCHEMAS_PATH" \
        --prefix 'XDG_DATA_DIRS' : "$out/share"
    done

    wrapProgram $out/libexec/gnome-session-binary \
      --set 'GSETTINGS_BACKEND' 'dconf' \
      --prefix 'GIO_EXTRA_MODULES' : "$GIO_EXTRA_MODULES" \
      --prefix 'GI_TYPELIB_PATH' : "$GI_TYPELIB_PATH" \
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

  meta = with lib; {
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
