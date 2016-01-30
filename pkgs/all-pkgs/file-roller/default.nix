{ stdenv, fetchurl, glib, pkgconfig, intltool, itstool, libxml2, libarchive
, attr, bzip2, acl, makeWrapper, librsvg, gdk_pixbuf
, adwaita-icon-theme, gtk3 }:

stdenv.mkDerivation rec {
  name = "file-roller-3.16.4";

  src = fetchurl {
    url = mirror://gnome/sources/file-roller/3.16/file-roller-3.16.4.tar.xz;
    sha256 = "5455980b2c9c7eb063d2d65560ae7ab2e7f01b208ea3947e151680231c7a4185";
  };

  # TODO: support nautilus
  # it tries to create {nautilus}/lib/nautilus/extensions-3.0/libnautilus-fileroller.so

  buildInputs = [ glib pkgconfig gtk3 intltool itstool libxml2 libarchive
                  adwaita-icon-theme attr bzip2 acl gdk_pixbuf librsvg
                  makeWrapper ];

  preFixup = ''
    wrapProgram "$out/bin/file-roller" \
      --prefix XDG_DATA_DIRS : "$XDG_ICON_DIRS:$GSETTINGS_SCHEMAS_PATH:$out/share"
  '';

  meta = with stdenv.lib; {
    homepage = https://wiki.gnome.org/Apps/FileRoller;
    description = "Archive manager for the GNOME desktop environment";
    platforms = platforms.linux;
    #maintainers = gnome3.maintainers;
  };
}
