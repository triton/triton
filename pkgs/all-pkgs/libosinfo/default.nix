{ stdenv
, fetchurl
, gettext
, intltool

, check
, glib
, gobject-introspection
, hwdata
, libsoup
, libxml2
, libxslt
, vala
}:

with {
  inherit (stdenv.lib)
    enFlag;
};

stdenv.mkDerivation rec {
  name = "libosinfo-0.3.0";

  src = fetchurl {
    url = "https://fedorahosted.org/releases/l/i/libosinfo/${name}.tar.gz";
    sha256 = "1g7g5hc4lhi4y0j3mbcj19hawlqkflni1zk4aggrx49fg5l392jk";
  };

  nativeBuildInputs = [
    gettext
    intltool
  ];

  buildInputs = [
    check
    glib
    gobject-introspection
    hwdata
    libsoup
    libxml2
    libxslt
    vala
  ];

  configureFlags = [
    "--disable-werror"
    "--disable-maintainer-mode"
    "--enable-nls"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--disable-tests"
    (enFlag "introspection" (gobject-introspection != null) null)
    (enFlag "vala" (vala != null) null)
    "--disable-coverage"
    "--with-usb-ids-path=${hwdata}/data/hwdata/usb.ids"
    "--with-pci-ids-path=${hwdata}/data/hwdata/pci.ids"
  ];

  meta = with stdenv.lib; {
    description = "GObject library for managing information about real/virtual OSes";
    homepage = http://libosinfo.org/;
    license = with licenses; [
      lgpl21
      gpl2
    ];
    maintainers = with maintainers; [ ];
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}
