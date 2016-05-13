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

let
  inherit (stdenv.lib)
    enFlag;
in

stdenv.mkDerivation rec {
  name = "file-roller-${version}";
  versionMajor = "3.20";
  versionMinor = "2";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/file-roller/${versionMajor}/${name}.tar.xz";
    sha256Url = "mirror://gnome/sources/file-roller/${versionMajor}/${name}.sha256sum";
    sha256 = "93188a7ac9285cb85551c327082aeaeb51ac39a9722cb96b0e29d5ec2ae353c6";
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
    licenses = licenses.free;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
