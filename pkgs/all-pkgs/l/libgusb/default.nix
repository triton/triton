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
  name = "libgusb-0.2.10";

  src = fetchurl {
    url = "https://people.freedesktop.org/~hughsient/releases/${name}.tar.xz";
    multihash = "QmNsvtiRfjoWVwKYg4Td8xrcm97L4cWLAYhridmRffKEKB";
    sha256 = "5c0442f5e00792bea939bbd16df09245740ae0d8b6ad9890d09189e1f4a3a17a";
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
