{ stdenv
, fetchurl
, gettext
, intltool
, lib

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
  inherit (lib)
    boolEn;
in
stdenv.mkDerivation rec {
  name = "libosinfo-1.0.0";

  src = fetchurl {
    url = "https://releases.pagure.org/libosinfo/${name}.tar.gz";
    hashOutput = false;
    sha256 = "f7b425ecde5197d200820eb44401c5033771a5d114bd6390230de768aad0396b";
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
    "--${boolEn (gobject-introspection != null)}-introspection"
    "--${boolEn (vala != null)}-vala"
    "--disable-coverage"
    "--with-usb-ids-path=${hwdata}/share/hwdata/usb.ids"
    "--with-pci-ids-path=${hwdata}/share/hwdata/pci.ids"
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      pgpKeyFingerprint = "DAF3 A6FD B26B 6291 2D0E  8E3F BE86 EBB4 1510 4FDF";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with lib; {
    description = "GObject library for managing information about real/virtual OSes";
    homepage = https://libosinfo.org/;
    license = with licenses; [
      lgpl21
      gpl2
    ];
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      x86_64-linux;
  };
}
