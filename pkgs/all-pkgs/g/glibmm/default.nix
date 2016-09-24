{ stdenv
, fetchurl

, glib
, libsigcxx

, channel
}:

let
  source = (import ./sources.nix { })."${channel}";
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

  meta = with stdenv.lib; {
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
