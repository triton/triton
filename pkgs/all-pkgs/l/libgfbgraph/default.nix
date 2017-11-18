{ stdenv
, fetchurl
, intltool
, lib

, glib
, gnome-online-accounts
, gobject-introspection
, json-glib
, libsoup
, rest
}:

let
  channel = "0.2";
  version = "${channel}.3";
in
stdenv.mkDerivation rec {
  name = "gfbgraph-${version}";

  src = fetchurl {
    url = "mirror://gnome/sources/gfbgraph/${channel}/${name}.tar.xz";
    sha256 = "1dp0v8ia35fxs9yhnqpxj3ir5lh018jlbiwifjfn8ayy7h47j4fs";
  };

  buildInputs = [
    glib
    gnome-online-accounts
    gobject-introspection
    json-glib
    libsoup
    rest
  ];

  configureFlags = [
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--enable-introspection"
  ];

  meta = with lib; {
    description = "A GObject library for Facebook Graph API";
    homepage = https://git.gnome.org/browse/libgfbgraph/;
    license = licenses.lgpl21Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
