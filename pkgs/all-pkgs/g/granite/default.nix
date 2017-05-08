{ stdenv
, fetchzip
, cmake
, gettext
, lib
, perl

, atk
, cairo
, gdk-pixbuf
, glib
, gobject-introspection
, gtk3
, hicolor-icon-theme
, libgee
, pango
, vala
}:

let
  channel = "0.4";
  version = "${channel}.1";
in
stdenv.mkDerivation rec {
  name = "granite-${version}";

  src = fetchzip {
    version = 3;
    url = "https://github.com/elementary/granite/archive/${version}.tar.gz";
    sha256 = "21d4e6e1ab5280fbe627f5b01c5f8f0e7cc606328ef7a7c17343a9ea463f7039";
  };

  nativeBuildInputs = [
    cmake
    gettext
    perl
  ];

  buildInputs = [
    atk
    cairo
    gdk-pixbuf
    glib
    libgee
    gobject-introspection
    gtk3
    hicolor-icon-theme
    pango
    vala
  ];

  preConfigure = ''
    cmakeFlagsArray=(
      "-DINTROSPECTION_GIRDIR=$out/share/gir-1.0/"
      "-DINTROSPECTION_TYPELIBDIR=$out/lib/girepository-1.0"
    )
  '';

  meta = with lib; {
    description = "An extension to GTK+ used by elementary OS";
    homepage = https://github.com/elementary/granite/;
    license = licenses.lgpl3;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
