{ stdenv
, fetchurl
, gettext
, intltool
, makeWrapper

, adwaita-icon-theme
, appstream-glib
, dconf
, gdk-pixbuf
, glib
, gtk3
, libxml2
}:

let
  inherit (stdenv.lib)
    enFlag;
in
stdenv.mkDerivation rec {
  name = "dconf-editor-${version}";
  versionMajor = "3.20";
  versionMinor = "3";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome-insecure/sources/dconf-editor/${versionMajor}/${name}.tar.xz";
    sha256Url = "mirror://gnome-secure/sources/dconf-editor/${versionMajor}/${name}.sha256sum";
    sha256 = "a8721499a277550b28d8dd94dafbea6efeb95fa153020da10603d0d4d628c579";
  };

  nativeBuildInputs = [
    gettext
    intltool
    makeWrapper
  ];

  buildInputs = [
    adwaita-icon-theme
    appstream-glib
    dconf
    gdk-pixbuf
    glib
    gtk3
    libxml2
  ];

  configureFlags = [
    "--enable-schemas-compile"
    (enFlag "appstream-util" (appstream-glib != null) null)
    "--enable-nls"
  ];

  preFixup = ''
    wrapProgram $out/bin/dconf-editor \
      --set 'GDK_PIXBUF_MODULE_FILE' "$GDK_PIXBUF_MODULE_FILE" \
      --set 'GSETTINGS_BACKEND' 'dconf' \
      --prefix 'GIO_EXTRA_MODULES' : "$GIO_EXTRA_MODULES" \
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
    platforms = with platforms;
      x86_64-linux;
  };
}
