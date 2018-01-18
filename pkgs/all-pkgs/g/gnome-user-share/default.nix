{ stdenv
, intltool
, fetchurl
, apache-httpd
, nautilus
, gtk3
, libxml2
, gnused
, bash
, makeWrapper
, itstool
, libnotify
, libtool
, mod_dnssd
, librsvg
, gdk-pixbuf
, file
, libcanberra
, glib
, adwaita-icon-theme
}:

stdenv.mkDerivation rec {
  name = "gnome-user-share-${version}";
  versionMajor = "3.18";
  versionMinor = "3";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-user-share/${versionMajor}/${name}.tar.xz";
    sha256Url = "mirror://gnome/sources/gnome-user-share/${versionMajor}/${name}.sha256sum";
    sha256 = "3092fa7ad137531e35484195dde4ecbbc75a8a3d9b8209aef4c852717cf4bbf1";
  };

  NIX_CFLAGS_COMPILE = "-I${glib}/include/gio-unix-2.0";

  #preConfigure = ''
  #  sed -i data/dav_user_2.2.conf \
  #    -e 's,^LoadModule dnssd_module.\+,LoadModule dnssd_module ${mod_dnssd}/modules/mod_dnssd.so,'
  #'';

  configureFlags = [ "--with-httpd=${apache-httpd}/bin/httpd"
                     "--with-modules-path=${apache-httpd}/modules"
                     "--disable-bluetooth"
                     "--with-nautilusdir=$(out)/lib/nautilus/extensions-3.0" ];

  buildInputs = [
    adwaita-icon-theme
    gtk3
    glib
    intltool
    itstool
    libxml2
    libtool
    makeWrapper
    file
    gdk-pixbuf
    librsvg
    nautilus
    libnotify
    libcanberra
  ];

  postInstall = ''
    mkdir -p $out/share/gsettings-schemas/$name
    mv $out/share/glib-2.0 $out/share/gsettings-schemas/$name
    ${glib}/bin/glib-compile-schemas \
      $out/share/gsettings-schemas/$name/glib-2.0/schemas
  '';

  preFixup = ''
    wrapProgram "$out/libexec/gnome-user-share-webdav" \
      --set GDK_PIXBUF_MODULE_FILE "${gdk-pixbuf.loaders.cache}" \
      --prefix XDG_DATA_DIRS : "$out/share" \
      --prefix XDG_DATA_DIRS : "$XDG_ICON_DIRS" \
      --prefix XDG_DATA_DIRS : "$GSETTINGS_SCHEMAS_PATH"
  '';

  doCheck = true;

  meta = with stdenv.lib; {
    homepage = https://help.gnome.org/users/gnome-user-share/3.8;
    description = "Service that exports the contents of the Public folder in your home directory on the local network";
    maintainers = gnome3.maintainers;
    license = licenses.gpl2;
    platforms = with platforms;
      x86_64-linux;
  };
}
