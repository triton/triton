{ stdenv
, fetchurl
, gettext
, lib
, meson
, ninja

, glib
, gobject-introspection
}:

let
  channel = "1.4";
  version = "${channel}.4";
in
stdenv.mkDerivation rec {
  name = "json-glib-${version}";

  src = fetchurl {
    url = "mirror://gnome/sources/json-glib/${channel}/${name}.tar.xz";
    hashOutput = false;
    sha256 = "720c5f4379513dc11fd97dc75336eb0c0d3338c53128044d9fabec4374f4bc47";
  };

  nativeBuildInputs = [
    gettext
    meson
    ninja
  ];

  buildInputs = [
    glib
    gobject-introspection
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
    description = "(de)serialization support for JSON";
    homepage = http://live.gnome.org/JsonGlib;
    license = licenses.lgpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
