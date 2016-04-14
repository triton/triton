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
, gtk3
, json-glib
, mesa_noglu
, mutter
, systemd_lib
, upower
, xorg
}:

let
  inherit (stdenv.lib)
    enFlag
    optionals
    wtFlag;
in

stdenv.mkDerivation rec {
  name = "gnome-session-${version}";
  versionMajor = "3.20";
  versionMinor = "1";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-session/${versionMajor}/${name}.tar.xz";
    sha256Url = "mirror://gnome/sources/gnome-session/${versionMajor}/${name}.sha256sum";
    sha256 = "2ae9f53dc74f851222fbefbe0dc08db0a78cc76ceeb156f92ebd4d40fd038913";
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
    gtk3
    json-glib
    mesa_noglu
    mutter # gschemas
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
    (enFlag "gconf" (gconf != null) null)
    (enFlag "systemd" (systemd_lib != null) null)
    "--disable-consolekit"
    "--disable-docbook-docs"
    "--disable-man"
    "--enable-nls"
    "--enable-schemas-compile"
    "--enable-ipv6"
    (wtFlag "xtrans" (xorg != null) null)
  ];

  preFixup = ''
    wrapProgram $out/libexec/gnome-session-binary \
      --set 'GSETTINGS_BACKEND' 'dconf' \
      --prefix 'GIO_EXTRA_MODULES' : "$GIO_EXTRA_MODULES" \
      --prefix 'GI_TYPELIB_PATH' : "$GI_TYPELIB_PATH" \
      --prefix 'XDG_DATA_DIRS' : "$GSETTINGS_SCHEMAS_PATH" \
      --prefix 'XDG_DATA_DIRS' : "$out/share" \
      --prefix 'XDG_DATA_DIRS' : "$XDG_ICON_DIRS"
  '';

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
