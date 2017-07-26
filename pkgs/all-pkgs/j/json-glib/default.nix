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
  inherit (lib)
    boolEn;

  versionMajor = "1.3";
  versionMinor = "2";
  version = "${versionMajor}.${versionMinor}";
in
stdenv.mkDerivation rec {
  name = "json-glib-${version}";

  src = fetchurl {
    url = "mirror://gnome/sources/json-glib/${versionMajor}/${name}.tar.xz";
    hashOutput = false;
    sha256 = "f6a80f42e63a3267356f20408bf91a1696837aa66d864ac7de2564ecbd332a7c";
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

  # Fix use of absolute filenames
  postPatch = ''
    sed -i 's,@filename@,@basename@,g' json-glib/json-enum-types.h.in
  '';

  doCheck = true;

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Url = "https://download.gnome.org/sources/json-glib/${versionMajor}/"
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
