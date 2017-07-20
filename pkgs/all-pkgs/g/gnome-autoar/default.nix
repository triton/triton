{ stdenv
, atk
, gdk-pixbuf
, fetchurl
, lib
, pango

, glib
, gobject-introspection
, gtk_3
, libarchive
}:

let
  inherit (lib)
    boolEn;

  channel = "0.2";
  version = "${channel}.2";
in
stdenv.mkDerivation rec {
  name = "gnome-autoar-${version}";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-autoar/${channel}/${name}.tar.xz";
    hashOutput = false;
    sha256 = "e1fe2c06eed30305c38bf0939c72b0e51b4716658e2663a0cf4a4bf57874ca62";
  };

  nativeBuildInputs = [
    atk
    gdk-pixbuf
    gobject-introspection
    pango
  ];

  buildInputs = [
    glib
    gtk_3
    libarchive
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--disable-schemas-compile"
    "--disable-debug"
    "--enable-compile-warnings"
    "--disable-iso-c"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--${boolEn (gobject-introspection != null)}-gobject-introspection"
    "--disable-vala"
    "--${boolEn (gtk_3 != null)}-gtk"
  ];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Url = "https://download.gnome.org/sources/gnome-autoar/${channel}/"
        + "${name}.sha256sum";
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "A file manager for the GNOME desktop";
    homepage = https://wiki.gnome.org/Apps/Nautilus;
    license = with licenses; [
      fdl11
      gpl2Plus
      lgpl2Plus
    ];
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
