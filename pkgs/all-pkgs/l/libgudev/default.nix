{ stdenv
, fetchurl
, lib

, glib
, gobject-introspection
, systemd_lib
}:

let
  inherit (lib)
    boolEn;

  version = "231";
in
stdenv.mkDerivation rec {
  name = "libgudev-${version}";

  src = fetchurl {
    url = "mirror://gnome/sources/libgudev/${version}/${name}.tar.xz";
    hashOutput = false;
    sha256 = "3b1ef99d4a8984c35044103d8ddfc3cc52c80035c36abab2bcc5e3532e063f96";
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
    "--${boolEn (gobject-introspection != null)}-introspection"
    "--disable-umockdev"
  ];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Url = "https://download.gnome.org/sources/libgudev/${version}/"
        + "${name}.sha256sum";
      failEarly = true;
    };
  };

  meta = with lib; {
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
