{ stdenv
, fetchurl
, help2man
, lib
, meson
, ninja

, cairo
, fontconfig
, freetype
, glib
, gobject-introspection
, harfbuzz_lib
, libx11
, xorg
}:

assert xorg != null ->
  xorg.libX11 != null
  && xorg.libXft != null
  && xorg.libXrender != null;

let
  inherit (lib)
    optionals
    optionalString;

  versionMajor = "1.40";
  versionMinor = "7";
  version = "${versionMajor}.${versionMinor}";
in
stdenv.mkDerivation rec {
  name = "pango-${version}";

  src = fetchurl {
    url = "mirror://gnome/sources/pango/${versionMajor}/${name}.tar.xz";
    hashOutput = false;
    sha256 = "517645c00c4554e82c0631e836659504d3fd3699c564c633fccfdfd37574e278";
  };

  nativeBuildInputs = [
    help2man
    meson
    ninja
  ];

  buildInputs = [
    cairo
    fontconfig
    freetype
    glib
    gobject-introspection
    harfbuzz_lib
    libx11
  ] ++ optionals (xorg != null) [
    xorg.libXft
    xorg.libXrender
  ];

  postPatch = /* FIXME: Fixed in >1.40.7 */ ''
    sed -i pango/meson.build \
      -e 's/symbols_prefix/symbol_prefix/g'
  '' +  /* FIXME: Files are missing from 1.40.7 release for some reason */ ''
    cat > pango/pango-features.h.meson <<EOF
    #ifndef PANGO_FEATURES_H
    #define PANGO_FEATURES_H

    #mesondefine PANGO_VERSION_MAJOR
    #mesondefine PANGO_VERSION_MINOR
    #mesondefine PANGO_VERSION_MICRO

    #define PANGO_VERSION_STRING "@PANGO_VERSION_MAJOR@.@PANGO_VERSION_MINOR@.@PANGO_VERSION_MICRO@"

    #endif /* PANGO_FEATURES_H */
    EOF

    for i in {1..9}; do
      touch tests/markups/{fail,valid}-$i.{expected,markup}
    done
  '';

  mesonFlags = [
    "-Denable_docs=false"  # gtk-doc
  ];

  # preCheck = /* Fontconfig fails to load default config in test */
  #     optionalString doCheck ''
  #   export FONTCONFIG_FILE="${fontconfig}/etc/fonts/fonts.conf"
  # '';

  doCheck = false;  # FIXME: files missing from release
  buildDirCheck = false; # FIXME

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Url = "https://download.gnome.org/sources/pango/${versionMajor}/"
        + "${name}.sha256sum";
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "A library for laying out and rendering of text";
    homepage = http://www.pango.org/;
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
