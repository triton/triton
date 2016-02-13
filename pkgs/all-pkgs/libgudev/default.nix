{ stdenv
, fetchurl

, glib
, gobject-introspection
, udev
}:

with {
  inherit (stdenv.lib)
    enFlag;
};

stdenv.mkDerivation rec {
  name = "libgudev-${version}";
  version = "230";

  src = fetchurl {
    url = "https://download.gnome.org/sources/libgudev/${version}/${name}.tar.xz";
    sha256 = "063w6j35n0i0ssmv58kivc1mw4070z6fzb83hi4xfrhcxnn7zrx2";
  };

  buildInputs = [
    glib
    gobject-introspection
    udev
  ];

  configureFlags = [
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    (enFlag "introspection" (gobject-introspection != null) null)
  ];

  meta = with stdenv.lib; {
    description = "GObject bindings for udev";
    homepage = https://wiki.gnome.org/Projects/libgudev;
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}
