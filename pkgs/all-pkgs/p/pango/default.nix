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
  version = "${channel}.2";
in
stdenv.mkDerivation rec {
  name = "pango-${version}";

  src = fetchurl {
    url = "mirror://gnome/sources/pango/${channel}/${name}.tar.xz";
    hashOutput = false;
    sha256 = "b1e416b4d40416ef6c8224cf146492b86848703264ba88f792290992cf3ca1e2";
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
