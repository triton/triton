{ stdenv
, fetchurl
, help2man
, lib
, meson
, ninja

, cairo
, fontconfig
, freetype
, fribidi
, glib
, gobject-introspection
, harfbuzz_lib
, libx11
, libxft
, libxrender
}:

let
  inherit (lib)
    optionals
    optionalString;

  channel = "1.42";
  version = "${channel}.0";
in
stdenv.mkDerivation rec {
  name = "pango-${version}";

  src = fetchurl {
    url = "mirror://gnome/sources/pango/${channel}/${name}.tar.xz";
    hashOutput = false;
    sha256 = "9924d88a3dcedff753f0763814a1605307c5c9c931413b8b47ea7267d1b19446";
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
    fribidi
    glib
    gobject-introspection
    harfbuzz_lib
    libx11
    libxft
    libxrender
  ];

  mesonFlags = [
    "-Denable_docs=false"  # gtk-doc
    "-Dgir=true"
  ];

  postPatch = ''
    # Fix list being cast to a string
    sed -i meson.build \
      -e "/PKGCONFIG_CAIRO_REQUIRES/ s/pangocairo_requires/'''.join(pangocairo_requires)/"
  '';

  # preCheck = /* Fontconfig fails to load default config in test */
  #     optionalString doCheck ''
  #   export FONTCONFIG_FILE="${fontconfig}/etc/fonts/fonts.conf"
  # '';

  doCheck = false;  # FIXME: files missing from release

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Url = "https://download.gnome.org/sources/pango/${channel}/"
        + "${name}.sha256sum";
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "A library for layout and rendering of text";
    homepage = http://www.pango.org/;
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
