{ stdenv
, fetchurl
, intltool
, libxslt
, makeWrapper

, adwaita-icon-theme
, dbus_glib
, gconf
, glib
, gnome-desktop
, gnome-settings-daemon
, gsettings-desktop-schemas
, gtk3
, json-glib
, mesa_noglu
, systemd
, upower
, xorg
}:

stdenv.mkDerivation rec {
  name = "gnome-session-${version}";
  versionMajor = "3.18";
  versionMinor = "1.2";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-session/${versionMajor}/${name}.tar.xz";
    sha256 = "b37d823d57ff2e3057401a426279954699cfe1e44e59a4cbdd941687ff928a45";
  };

  nativeBuildInputs = [
    intltool
    libxslt
    makeWrapper
  ];

  buildInputs = [
    adwaita-icon-theme
    dbus_glib
    gconf
    glib
    gnome-desktop
    gnome-settings-daemon
    gsettings-desktop-schemas
    gtk3
    json-glib
    mesa_noglu
    systemd
    upower
    xorg.libSM
    xorg.libX11
    xorg.libXcomposite
    xorg.libXext
    xorg.xtrans
  ];

  configureFlags = "--enable-systemd";

  preFixup = ''
    wrapProgram "$out/bin/gnome-session" \
      --prefix GI_TYPELIB_PATH : "$GI_TYPELIB_PATH" \
      --suffix XDG_DATA_DIRS : "$out/share:$GSETTINGS_SCHEMAS_PATH"
  '';

  meta = with stdenv.lib; {
    platforms = platforms.linux;
    maintainers = gnome3.maintainers;
  };

}
