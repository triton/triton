{ stdenv
, fetchurl
, lib
#, meson
#, ninja
, vala

, glib
, gobject-introspection
, libxml2
}:

let
  channel = "0.12";
  version = "${channel}.11";
in
stdenv.mkDerivation rec {
  name = "gupnp-av-${version}";

  src = fetchurl {
    url = "mirror://gnome/sources/gupnp-av/${channel}/${name}.tar.xz";
    hashOutput = false;
    sha256 = "689dcf1492ab8991daea291365a32548a77d1a2294d85b33622b55cca9ce6fdc";
  };

  nativeBuildInputs = [
    #meson
    #ninja
    vala
  ];

  buildInputs = [
    glib
    gobject-introspection
    libxml2
  ];

  configureFlags = [
    "--enable-introspection"
  ];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      fullOpts = {
        sha256Urls =
          map (u: lib.replaceStrings ["tar.xz"] ["sha256sum"] u) src.urls;
      };
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "Utility library to ease the handling UPnP A/V profiles";
    homepage = http://gupnp.org/;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
