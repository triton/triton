{ stdenv
, fetchurl
, lib

, glib
, libsigcxx

, channel
}:

let
  sources = {
    "2.52" = {
      version = "2.52.0";
      sha256 = "81b8abf21c645868c06779abc5f34efc1a51d5e61589dab2a2ed67faa8d4811e";
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
    "--disable-maintainer-mode"
    "--enable-schemas-compile"
    "--disable-documentation"
    "--disable-debug-refcounting"
    "--enable-warnings"
    # Deprecated apis used by gtkmm2
    "--enable-deprecated-api"
    "--without-libstdc-doc"
    "--without-libsigc-doc"
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
