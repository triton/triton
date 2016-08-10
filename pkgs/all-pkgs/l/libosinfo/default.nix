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

let
  inherit (stdenv.lib)
    enFlag;
in

stdenv.mkDerivation rec {
  name = "libosinfo-0.3.1";

  src = fetchurl {
    url = "https://fedorahosted.org/releases/l/i/libosinfo/${name}.tar.gz";
    sha256 = "50b272943d68b77d5259f72be860acfd048126bc27e7aa9c2f9c77a7eacf3894";
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
    platforms = with platforms;
      x86_64-linux;
  };
}
