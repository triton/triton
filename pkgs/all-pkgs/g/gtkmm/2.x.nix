{ stdenv
, fetchTritonPatch
, fetchurl
, lib

, atkmm
, cairomm
, gdk-pixbuf
, glibmm
, gtk_2
, pangomm
}:

let
  inherit (lib)
    boolEn;

  channel = "2.24";
  version = "${channel}.5";
in
stdenv.mkDerivation rec {
  name = "gtkmm-${version}";

  src = fetchurl {
    url = "mirror://gnome/sources/gtkmm/${channel}/${name}.tar.xz";
    hashOutput = false;
    sha256 = "0680a53b7bf90b4e4bf444d1d89e6df41c777e0bacc96e9c09fc4dd2f5fe6b72";
  };

  buildInputs = [
    atkmm
    cairomm
    gdk-pixbuf
    glibmm
    gtk_2
    pangomm
  ];

  configureFlags = [
    "--${boolEn (atkmm != null)}-api-atkmm"
    "--disable-api-maemo-extensions"
    "--enable-deprecated-api"  # Requires deprecated api
    "--disable-documentation"
    "--without-libstdc-doc"
    "--without-libsigc-doc"
    "--without-glibmm-doc"
    "--without-cairomm-doc"
    "--without-pangomm-doc"
    "--without-atkmm-doc"
  ];

  doCheck = true;

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Url = "https://download.gnome.org/sources/gtkmm/${channel}/"
        + "${name}.sha256sum";
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "C++ interface for GTK+";
    homepage = http://gtkmm.org/;
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
