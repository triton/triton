{ stdenv
, fetchurl
, libtool
, lib

, glib
, gobject-introspection
, libcanberra
, vala
}:

let
  channel = "1.0";
  version = "${channel}.2";
in  
stdenv.mkDerivation rec {
  name = "gsound-${version}";

  src = fetchurl {
    url = "mirror://gnome/sources/gsound/${channel}/${name}.tar.xz";
    sha256 = "0lwfwx2c99qrp08pfaj59pks5dphsnxjgrxyadz065d8xqqgza5v";
  };

  nativeBuildInputs = [
    libtool
    vala
  ];

  buildInputs = [
    glib
    gobject-introspection
    libcanberra
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-compile-warnings"
    "--disable-Werror"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--enable-introspection"
    "--enable-vala"
  ];

  meta = with lib; {
    description = "GObject wrapper around the libcanberra sound event library";
    homepage = https://wiki.gnome.org/Projects/GSound;
    license = licenses.lgpl21Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
