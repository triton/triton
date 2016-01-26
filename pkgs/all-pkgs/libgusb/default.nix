{ stdenv
, autoreconfHook
, fetchurl
, gettext

, gobject-introspection
, libxslt
, glib
, systemd
, libusb
, vala
}:

with {
  inherit (stdenv.lib)
    enFlag;
};

stdenv.mkDerivation rec {
  name = "libgusb-0.2.8";

  src = fetchurl {
    url = "http://people.freedesktop.org/~hughsient/releases/${name}.tar.xz";
    sha256 = "1vcy71wjy0ifrmzd2j27dx523bn4z4z57jzxb6724nql47pnkhm9";
  };

  nativeBuildInputs = [
    autoreconfHook
    gettext
  ];

  buildInputs = [
    glib
    gobject-introspection
    libusb
    vala
  ];

  configureFlags = [
    (enFlag "introspection" (gobject-introspection != null) null)
    (enFlag "vala" (vala != null) null)
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--disable-tests"
  ];

  meta = with stdenv.lib; {
    description = "GObject wrapper for libusb";
    homepage = https://github.com/hughsie/libgusb;
    license = licenses.lgpl21Plus;
    maintainers = with maintainers; [ ];
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}
