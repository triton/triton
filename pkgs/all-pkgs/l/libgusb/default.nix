{ stdenv
, fetchurl
, gettext

, gobject-introspection
, libxslt
, glib
, libusb
, vala
}:

stdenv.mkDerivation rec {
  name = "libgusb-0.2.9";

  src = fetchurl {
    url = "https://people.freedesktop.org/~hughsient/releases/${name}.tar.xz";
    sha256 = "7320bdcd0ab1750d314fa86f48bd2cc186b9e33332314403779af9772fedde14";
  };

  nativeBuildInputs = [
    gettext
  ];

  buildInputs = [
    glib
    gobject-introspection
    libusb
    vala
  ];

  configureFlags = [
    "--enable-introspection"
    "--enable-vala"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--disable-tests"
  ];

  meta = with stdenv.lib; {
    description = "GObject wrapper for libusb";
    homepage = https://github.com/hughsie/libgusb;
    license = licenses.lgpl21Plus;
    maintainers = with maintainers; [
      codeyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
