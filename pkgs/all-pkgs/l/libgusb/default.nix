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
  name = "libgusb-0.2.11";

  src = fetchurl {
    url = "https://people.freedesktop.org/~hughsient/releases/${name}.tar.xz";
    multihash = "QmRbs4mYpj8vfNSEnViiYi1KZro2qAE9hrtuyaiWWaFtC3";
    sha256 = "9cb143493fab1dc3d0d0fdba2114b1d8ec8c5b6fad05bfd0f7700e4e4ff8f7de";
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
