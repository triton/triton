{ stdenv
, fetchTritonPatch
, fetchurl
, gettext
, intltool

, adwaita-icon-theme
, atk
, dbus_glib
, dconf
, exempi
, gdk-pixbuf
, glib
, gnome-desktop
, gobject-introspection
, gsettings-desktop-schemas
, gtk3
, gvfs
, libexif
, libnotify
, librsvg
, libunique
, libxml2
, pango
, shared_mime_info
, tracker
, xorg
}:

stdenv.mkDerivation rec {
  name = "nautilus-${version}";
  versionMajor = "3.18";
  versionMinor = "5";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/nautilus/${versionMajor}/${name}.tar.xz";
    sha256 = "05fclrqmk024pjskwlp4bcqd8bsyxv9awaznv3cwwk1bab02gab0";
  };

  patches = [
    (fetchTritonPatch {
      rev = "734f89c9d36781e3f50f30dc9aa33d071136dbd0";
      file = "nautilus/extension_dir.patch";
      sha256 = "ebd28b1f94106562574bb43884565761a34f233bcefa0ab516bf82e7691ee764";
    })
  ];

  postPatch = ''
    sed -i configure \
      -e 's/DISABLE_DEPRECATED_CFLAGS=.*/DISABLE_DEPRECATED_CFLAGS=/'
  '';

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-schemas-compile"
    "--enable-nls"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--disable-profiling"
    "--enable-nst-extension"
    "--enable-exif"
    "--enable-xmp"
    # Flag is not a proper boolean
    #"--disable-empty-view"
    "--enable-packagekit"
    "--enable-more-warnings"
    "--enable-tracker"
    "--enable-introspection"
    "--disable-update-mimedb"
  ];

  nativeBuildInputs = [
    gettext
    intltool
  ];

  buildInputs = [
    adwaita-icon-theme
    atk
    dbus_glib
    dconf
    exempi
    gdk-pixbuf
    glib
    gnome-desktop
    gobject-introspection
    gsettings-desktop-schemas
    gtk3
    gvfs
    libexif
    libnotify
    librsvg
    libunique
    libxml2
    pango
    shared_mime_info
    tracker
    xorg.libX11
  ];

  preFixup = ''
    gnomeWrapperArgs+=(
      "--prefix PATH ':' '$GSETTINGS_SCHEMAS_PATH:${gvfs}/bin'"
    )
  '';

  meta = with stdenv.lib; {
    description = "A file manager for the GNOME desktop";
    homepage = https://wiki.gnome.org/Apps/Nautilus;
    license = with licenses; [
      fdl11
      gpl2Plus
      lgpl2Plus
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
