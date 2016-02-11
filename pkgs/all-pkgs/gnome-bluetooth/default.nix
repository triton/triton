{ stdenv
, fetchurl
, intltool
, itstool
, makeWrapper

, adwaita-icon-theme
, atk
, gdk-pixbuf
, glib
, gobject-introspection
, gtk3
, libcanberra
, libnotify
, libxml2
, pango
, udev
}:

with {
  inherit (stdenv.lib)
    enFlag;
};

# TODO: fix dconf gsettings backend support

stdenv.mkDerivation rec {
  name = "gnome-bluetooth-${version}";
  versionMajor = "3.18";
  versionMinor = "2";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-bluetooth/${versionMajor}/${name}.tar.xz";
    sha256 = "d8df073c331df0f97261869fb77ffcdbf4e3e4eaf460d3c3ed2b16e03d9c5398";
  };

  nativeBuildInputs = [
    intltool
    itstool
    makeWrapper
  ];

  buildInputs = [
    adwaita-icon-theme
    atk
    gdk-pixbuf
    glib
    gobject-introspection
    gtk3
    libcanberra
    libnotify
    libxml2
    pango
    udev
  ];

  postPatch =
    /* Regenerate gdbus-codegen files to allow using any glib version
    	 https://bugzilla.gnome.org/show_bug.cgi?id=758096 */ ''
    	rm -v lib/bluetooth-client-glue.{c,h}
    '';

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-nls"
    "--enable-schemas-compile"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--disable-desktop-update"
    "--disable-icon-update"
    (enFlag "introspection" (gobject-introspection != null) null)
    "--disable-debug"
    "--enable-compile-warnings"
    "--disable-iso-c"
    "--disable-documentation"
  ];

  preFixup = ''
    wrapProgram $out/bin/bluetooth-sendto \
      --set 'GDK_PIXBUF_MODULE_FILE' "$GDK_PIXBUF_MODULE_FILE" \
      --prefix 'XDG_DATA_DIRS' : "$GSETTINGS_SCHEMAS_PATH" \
      --prefix 'XDG_DATA_DIRS' : "$out/share" \
      --prefix 'XDG_DATA_DIRS' : "$XDG_ICON_DIRS"
  '';

  meta = with stdenv.lib; {
    description = "Bluetooth graphical utilities integrated with GNOME";
    homepage = https://wiki.gnome.org/Projects/GnomeBluetooth;
    license = with licenses; [
      fdl11
      gpl2Plus
      lgpl21Plus
    ];
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}
