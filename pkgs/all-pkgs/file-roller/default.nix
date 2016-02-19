{ stdenv
, fetchurl
, gettext
, intltool
, itstool
, makeWrapper

, adwaita-icon-theme
, cairo
, dconf
, file
, gdk-pixbuf
, glib
, gtk3
, json-glib
, libarchive
, libnotify
, libxml2
, nautilus
, pango
}:

with {
  inherit (stdenv.lib)
    enFlag;
};

stdenv.mkDerivation rec {
  name = "file-roller-3.16.4";

  src = fetchurl {
    url = mirror://gnome/sources/file-roller/3.16/file-roller-3.16.4.tar.xz;
    sha256 = "5455980b2c9c7eb063d2d65560ae7ab2e7f01b208ea3947e151680231c7a4185";
  };

  nativeBuildInputs = [
    gettext
    intltool
    itstool
    makeWrapper
  ];

  buildInputs = [
    adwaita-icon-theme
    dconf
    file
    gdk-pixbuf
    glib
    gtk3
    json-glib
    libarchive
    libnotify
    libxml2
    nautilus
  ];

  configureFlags = [
    "--enable-schemas-compile"
    "--disable-debug"
    "--disable-run-in-place"
    (enFlag "nautilus-actions" (nautilus != null) null)
    #"--enable-packagekit"
    (enFlag "notification" (libnotify != null) null)
    #"--enable-magic"
    (enFlag "libarchive" (libarchive != null) null)
    "--enable-nls"
    "--disable-deprecated"
  ];

  preInstall = ''
    installFlagsArray+=(
      "nautilus_extensiondir=$out/lib/nautilus/extensions-3.0"
    )
  '';

  preFixup = ''
    wrapProgram "$out/bin/file-roller" \
      --set 'GDK_PIXBUF_MODULE_FILE' "$GDK_PIXBUF_MODULE_FILE" \
      --set 'GSETTINGS_BACKEND' 'dconf' \
      --prefix 'GIO_EXTRA_MODULES' : "$GIO_EXTRA_MODULES" \
      --prefix XDG_DATA_DIRS : "$GSETTINGS_SCHEMAS_PATH" \
      --prefix XDG_DATA_DIRS : "$out/share" \
      --prefix XDG_DATA_DIRS : "$XDG_ICON_DIRS"
  '';

  meta = with stdenv.lib; {
    homepage = https://wiki.gnome.org/Apps/FileRoller;
    description = "Archive manager for the GNOME desktop environment";
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
