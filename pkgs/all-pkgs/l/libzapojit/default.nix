{ stdenv
, fetchurl
, gettext
, intltool
, lib

, glib
, gnome-online-accounts
, gobject-introspection
, gtk3
, json-glib
, libsoup
, rest
}:

let
  channel = "0.0";
  version = "${channel}.3";
in
stdenv.mkDerivation rec {
  name = "libzapojit-${version}";

  src = fetchurl {
    url = "mirror://gnome/sources/libzapojit/${channel}/${name}.tar.xz";
    sha256 = "0zn3s7ryjc3k1abj4k55dr2na844l451nrg9s6cvnnhh569zj99x";
  };

  nativeBuildInputs = [
    gettext
    intltool
  ];

  buildInputs = [
    glib
    gnome-online-accounts
    gobject-introspection
    gtk3
    json-glib
    libsoup
    rest
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--disable-debug"
    "--enable-introspection"
    "--enable-nls"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
  ];

  meta = with lib; {
    description = "GLib/GObject wrapper for SkyDrive and Hotmail REST APIs";
    homepage = https://git.gnome.org/browse/libzapojit;
    license = licenses.lgpl21;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
