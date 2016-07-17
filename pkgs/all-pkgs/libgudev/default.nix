{ stdenv
, fetchurl

, glib
, gobject-introspection
, systemd_lib
}:

let
  inherit (stdenv.lib)
    enFlag;

  version = "230";
in

stdenv.mkDerivation rec {
  name = "libgudev-${version}";

  src = fetchurl {
    url = "https://download.gnome.org/sources/libgudev/${version}/${name}.tar.xz";
    sha256 = "063w6j35n0i0ssmv58kivc1mw4070z6fzb83hi4xfrhcxnn7zrx2";
  };

  buildInputs = [
    glib
    gobject-introspection
    systemd_lib
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
    platforms = with platforms;
      x86_64-linux;
  };
}
