{ stdenv
, fetchurl
, gettext
, lib
, meson
, ninja

, glib
, gobject-introspection
, libarchive
, libgcrypt
, libxml2

, channel
}:

let
  sources = {
    "3.26" = {
      version = "3.26.3";
      sha256 = "0efd01b8a0a9770d52fe7354d298874ed845449b88f3f78f49290729fc2d448d";
    };
  };

  source = sources."${channel}";
in
stdenv.mkDerivation rec {
  name = "totem-pl-parser-${source.version}";

  src = fetchurl {
    url = "mirror://gnome/sources/totem-pl-parser/${channel}/${name}.tar.xz";
    hashOutput = false;
    inherit (source) sha256;
  };

  nativeBuildInputs = [
    gettext
    meson
    ninja
  ];

  buildInputs = [
    glib
    gobject-introspection
    libarchive
    libgcrypt
    libxml2
  ];

  mesonFlags = [
    "-Denable-quvi=no"  # FIXME
    "-Denable-libarchive=yes"
    "-Denable-libgcrypt=yes"
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
    description = "GObject library to parse and save playlist formats";
    homepage = https://wiki.gnome.org/Apps/Videos;
    license = licenses.lgpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
