{ stdenv, fetchurl, intltool, itstool, libtool, makeWrapper, pkgconfig
, apacheHttpd_2_2, file, gdk_pixbuf, glib, gnome3, gtk3, hicolor_icon_theme
, libcanberra_gtk3, libnotify, librsvg, libxml2, mod_dnssd, nautilus
, bluetoothSupport ? false # TODO: implement bluetooth support
}:

let
  inherit (stdenv.lib) enableFeature optionalString;
  majVer = "3.14";
in

stdenv.mkDerivation rec {
  name = "gnome-user-share-${majVer}.2";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-user-share/${majVer}/${name}.tar.xz";
    sha256 = "1s9fjzr161hy53i9ibk6aamc9af0cg8s151zj2fb6fxg67pv61bb";
  };

  NIX_CFLAGS_COMPILE = "-I${gnome3.glib}/include/gio-unix-2.0";

  configureFlags = [
    "--with-httpd=${apacheHttpd_2_2}/bin/httpd"
    "--with-modules-path=${apacheHttpd_2_2}/modules"
    (enableFeature bluetoothSupport "bluetooth")
    "--with-nautilusdir=$(out)/lib/nautilus/extensions-3.0"
  ];

  preConfigure = ''
    sed -e 's,^LoadModule dnssd_module.\+,LoadModule dnssd_module ${mod_dnssd}/modules/mod_dnssd.so,' -i data/dav_user_2.2.conf 
  '';

  nativeBuildInputs = [ intltool libtool itstool makeWrapper pkgconfig ];

  buildInputs = [
    file gdk_pixbuf glib gnome3.adwaita-icon-theme gtk3 hicolor_icon_theme
    libcanberra_gtk3 libnotify librsvg libxml2 nautilus
  ];

  doCheck = true;

  postInstall = ''
    mkdir -p "$out/share/gsettings-schemas/$name"
    mv $out/share/glib-2.0 $out/share/gsettings-schemas/$name
    ${glib}/bin/glib-compile-schemas $out/share/gsettings-schemas/$name/glib-2.0/schemas
  '';

  preFixup = ''
    wrapProgram "$out/libexec/gnome-user-share-webdav" \
      --set GDK_PIXBUF_MODULE_FILE "$GDK_PIXBUF_MODULE_FILE" \
      --prefix XDG_DATA_DIRS : "$out/share:$XDG_ICON_DIRS:$GSETTINGS_SCHEMAS_PATH"
  '' + optionalString bluetoothSupport ''
    wrapProgram "$out/libexec/gnome-user-share-obexftp" \
      --set GDK_PIXBUF_MODULE_FILE "$GDK_PIXBUF_MODULE_FILE" \
      --prefix XDG_DATA_DIRS : "$out/share:$XDG_ICON_DIRS:$GSETTINGS_SCHEMAS_PATH"
  '';

  meta = with stdenv.lib; {
    homepage = https://help.gnome.org/users/gnome-user-share/3.8;
    description = "Service that exports the contents of the Public folder in your home directory on the local network";
    maintainers = gnome3.maintainers;
    license = licenses.gpl2;
    platforms = platforms.linux;
  };
}
