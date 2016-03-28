{ stdenv
, fetchurl

, cairo
, fontconfig
, freetype
, glib
, gobject-introspection
, harfbuzz
, xorg
}:

with {
  inherit (stdenv.lib)
    enFlag
    optionalString
    wtFlag;
};

stdenv.mkDerivation rec {
  name = "pango-${version}";
  versionMajor = "1.40";
  versionMinor = "0";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/pango/${versionMajor}/${name}.tar.xz";
    sha256 = "da17985df314cb07d066ab5424f59c21ce973ece05b7de4df04d798ec8511c8b";
  };

  buildInputs = [
    cairo
    fontconfig
    freetype
    glib
    gobject-introspection
    harfbuzz
    xorg.libX11
    xorg.libXft
    xorg.libXrender
  ];

  postPatch =
    /* Test fails randomly */ optionalString doCheck ''
      sed -i tests/Makefile.in \
        -e 's,\(am__append_4 = testiter\) test-pangocairo-threads,\1,g'
    '';

  configureFlags = [
    "--enable-rebuilds"
    (enFlag "introspection" (gobject-introspection != null) null)
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--disable-doc-cross-reference"
    "--enable-Bsymbolic"
    "--disable-installed-tests"
    (wtFlag "xft" (xorg.libXft != null) null)
    (wtFlag "cairo" (cairo != null) null)
  ];

  # Does not respect --disable-gtk-doc
  postInstall = "rm -rvf $out/share/gtk-doc";

  preCheck =
    /* Fontconfig fails to load default config in test */
    optionalString doCheck ''
      export FONTCONFIG_FILE="${fontconfig}/etc/fonts/fonts.conf"
    '';

  doCheck = true;

  meta = with stdenv.lib; {
    description = "A library for laying out and rendering of text";
    homepage = http://www.pango.org/;
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
