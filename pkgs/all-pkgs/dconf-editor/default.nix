{ stdenv
, fetchurl
, gettext
, intltool
, makeWrapper

, adwaita-icon-theme
, dconf
, gdk-pixbuf
, glib
, gtk3
, libxml2
}:

stdenv.mkDerivation rec {
  name = "dconf-editor-${version}";
  versionMajor = "3.18";
  versionMinor = "2";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/dconf-editor/${versionMajor}/${name}.tar.xz";
    sha256 = "0xdwi7g1xdmgrc9m8ii62fp2zj114gsfpmgazlnhrcmmfi97z5d7";
  };

  nativeBuildInputs = [
    gettext
    intltool
    makeWrapper
  ];

  buildInputs = [
    adwaita-icon-theme
    dconf
    gdk-pixbuf
    glib
    gtk3
    libxml2
  ];

  configureFlags = [
    "--enable-schemas-compile"
    "--enable-nls"
  ];

  preFixup = ''
    wrapProgram $out/bin/dconf-editor \
      --set 'GDK_PIXBUF_MODULE_FILE' "$GDK_PIXBUF_MODULE_FILE" \
      --set 'GSETTINGS_BACKEND' 'dconf' \
      --prefix 'GIO_EXTRA_MODULES' : "${dconf}/lib/gio/modules" \
      --prefix 'XDG_DATA_DIRS' : "$GSETTINGS_SCHEMAS_PATH" \
      --prefix 'XDG_DATA_DIRS' : "$out/share" \
      --prefix 'XDG_DATA_DIRS' : "$XDG_ICON_DIRS"
  '';

  meta = with stdenv.lib; {
    description = "Graphical tool for editing the dconf configuration database";
    homepage = https://git.gnome.org/browse/dconf-editor;
    license = licenses.lgpl21Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}
