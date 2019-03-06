{ stdenv
, fetchurl
, lib
, meson
, ninja

, glib
, gdk-pixbuf
, gobject-introspection
, vala
, zlib
}:

let
  channel = "1.9";
  version = "${channel}.4";
in
stdenv.mkDerivation rec {
  name = "libmediaart-${version}";

  src = fetchurl {
    url = "mirror://gnome/sources/libmediaart/${channel}/${name}.tar.xz";
    hashOutput = false;
    sha256 = "a57be017257e4815389afe4f58fdacb6a50e74fd185452b23a652ee56b04813d";
  };

  nativeBuildInputs = [
    meson
    ninja
    vala
  ];

  buildInputs = [
    gdk-pixbuf
    glib
    gobject-introspection
    zlib
  ];

  mesonFlags = [
    "-Dimage_library=gdk-pixbuf"
    "-Dwith-docs=no"
  ];

  setVapidirInstallFlag = false;

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
    description = "Manages, extracts and handles media art caches";
    homepage = https://github.com/GNOME/libmediaart;
    license = licenses.lgpl21Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
