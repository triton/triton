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
  version = "0.5";
in
stdenv.mkDerivation rec {
  name = "granite-${version}";

  src = fetchzip {
    version = 3;
    url = "https://github.com/elementary/granite/archive/${version}.tar.gz";
    sha256 = "8b44bf680e2d53f2fb00dea9be48a0706cd1d9017b636dc9c96e4bee77782f6b";
  };

  nativeBuildInputs = [
    cmake
    gettext
    perl
    vala
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
