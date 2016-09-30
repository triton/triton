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

  version = "230";
in
stdenv.mkDerivation rec {
  name = "libgudev-${version}";

  src = fetchurl {
    url = "mirror://gnome/sources/libgudev/${version}/${name}.tar.xz";
    sha256 = "a2e77faced0c66d7498403adefcc0707105e03db71a2b2abd620025b86347c18";
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
