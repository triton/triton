{ stdenv
, desktop_file_utils
, fetchurl
, gnome_doc_utils
, intltool
, itstool
, libxml2
, makeWrapper
, util-linux_lib
, which

, adwaita-icon-theme
, appdata-tools
, dconf
, gdk-pixbuf
, glib
, gsettings-desktop-schemas
, gtk3
, nautilus
, vala
, vte
, xorg
}:

stdenv.mkDerivation rec {
  name = "gnome-terminal-${version}";
  versionMajor = "3.20";
  versionMinor = "2";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome-insecure/sources/gnome-terminal/${versionMajor}/${name}.tar.xz";
    sha256Url = "mirror://gnome-secure/sources/gnome-terminal/${versionMajor}/${name}.sha256sum";
    sha256 = "f5383060730f1de70af35e917f82d5b6a14d963ad9cfd6a0e705f90011645a23";
  };

  nativeBuildInputs = [
    desktop_file_utils
    gnome_doc_utils
    intltool
    itstool
    libxml2
    makeWrapper
    util-linux_lib
    which
  ];

  buildInputs = [
    adwaita-icon-theme
    appdata-tools
    dconf
    gdk-pixbuf
    glib
    gsettings-desktop-schemas
    gtk3
    nautilus
    vala
    vte
    xorg.libX11
  ];

  configureFlags = [
    "--disable-search-provider"
    "--disable-migration"
  ];

  preFixup = ''
    wrapProgram $out/libexec/gnome-terminal-server \
      --set 'GDK_PIXBUF_MODULE_FILE' "$GDK_PIXBUF_MODULE_FILE" \
      --set 'GSETTINGS_BACKEND' 'dconf' \
      --prefix 'GIO_EXTRA_MODULES' : "$GIO_EXTRA_MODULES" \
      --prefix 'XDG_DATA_DIRS' : "$GSETTINGS_SCHEMAS_PATH" \
      --prefix 'XDG_DATA_DIRS' : "$out/share" \
      --prefix 'XDG_DATA_DIRS' : "$XDG_ICON_DIRS"
  '';

  meta = with stdenv.lib; {
    description = "The Gnome Terminal";
    homepage = https://wiki.gnome.org/Apps/Terminal/;
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
