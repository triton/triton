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
  version = "${channel}.2";
in
stdenv.mkDerivation rec {
  name = "json-glib-${version}";

  src = fetchurl {
    url = "mirror://gnome/sources/json-glib/${channel}/${name}.tar.xz";
    sha256 = "2d7709a44749c7318599a6829322e081915bdc73f5be5045882ed120bb686dc8";
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

  postPatch = /* Remove hardcoded reference to the build directory */ ''
    sed -i json-glib/json-enum-types.h.in \
      -e '/@filename@/d'
  '';

  mesonFlags = [
    "-Dintrospection=true"
    "-Ddocs=false"
  ];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Url = "https://download.gnome.org/sources/json-glib/${channel}/"
        + "${name}.sha256sum";
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
