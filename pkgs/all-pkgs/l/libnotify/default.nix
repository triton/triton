{ stdenv
, fetchurl
, lib

, gdk-pixbuf
, glib
, gobject-introspection
}:

let
  inherit (lib)
    boolEn;

  channel = "0.7";
  version = "${channel}.7";
in
stdenv.mkDerivation rec {
  name = "libnotify-${version}";

  src = fetchurl {
    url = "mirror://gnome/sources/libnotify/${channel}/${name}.tar.xz";
    hashOutput = false;
    sha256 = "9cb4ce315b2655860c524d46b56010874214ec27e854086c1a1d0260137efc04";
  };

  buildInputs = [
    gdk-pixbuf
    glib
    gobject-introspection
  ];

  configureFlags = [
    "--disable-tests"
    "--${boolEn (gobject-introspection != null)}-introspection"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--disable-docbook-docs"
    "--enable-more-warnings"
  ];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Url = "https://download.gnome.org/sources/libnotify/${channel}/"
        + "${name}.sha256sum";
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "A library for sending desktop notifications";
    homepage = https://git.gnome.org/browse/libnotify;
    license = licenses.lgpl21Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
