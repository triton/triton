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
, libxrender
, xorg
}:

assert libx11 != null ->
  xorg.libXft != null;

let
  inherit (lib)
    optionals
    optionalString;

  versionMajor = "1.40";
  versionMinor = "11";
  version = "${versionMajor}.${versionMinor}";
in
stdenv.mkDerivation rec {
  name = "pango-${version}";

  src = fetchurl {
    url = "mirror://gnome/sources/pango/${versionMajor}/${name}.tar.xz";
    hashOutput = false;
    sha256 = "5b11140590e632739e4151cae06b8116160d59e22bf36a3ccd5df76d1cf0383e";
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
    libxrender
  ] ++ optionals (xorg != null) [
    xorg.libXft
  ];

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
