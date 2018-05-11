{ stdenv
, fetchurl
, lib

, glib
, libsigcxx

, channel
}:

let
  sources = {
    "2.56" = {
      version = "2.56.0";
      sha256 = "6e74fcba0d245451c58fc8a196e9d103789bc510e1eee1a9b1e816c5209e79a9";
    };
  };
  source = sources."${channel}";
in
stdenv.mkDerivation rec {
  name = "glibmm-${source.version}";

  src = fetchurl {
    url = "mirror://gnome/sources/glibmm/${channel}/${name}.tar.xz";
    hashOutput = false;
    inherit (source) sha256;
  };

  buildInputs = [
    glib
    libsigcxx
  ];

  configureFlags = [
    "--disable-schemas-compile"
    "--disable-documentation"
    "--enable-warnings"
    # Deprecated apis used by gtkmm2
    "--enable-deprecated-api"
  ];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Url = "https://download.gnome.org/sources/glibmm/${channel}/"
        + "${name}.sha256sum";
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "C++ interface to the GLib library";
    homepage = http://gtkmm.org/;
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
