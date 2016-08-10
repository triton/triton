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

let
  inherit (stdenv.lib)
    enFlag
    optionals
    optionalString
    wtFlag;
in

assert xorg != null ->
  xorg.libX11 != null
  && xorg.libXft != null
  && xorg.libXrender != null;

stdenv.mkDerivation rec {
  name = "pango-${version}";
  versionMajor = "1.40";
  versionMinor = "1";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/pango/${versionMajor}/${name}.tar.xz";
    sha256Url = "mirror://gnome/sources/pango/${versionMajor}/${name}.sha256sum";
    sha256 = "e27af54172c72b3ac6be53c9a4c67053e16c905e02addcf3a603ceb2005c1a40";
  };

  buildInputs = [
    cairo
    fontconfig
    freetype
    glib
    gobject-introspection
    harfbuzz
  ] ++ optionals (xorg != null) [
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
    (wtFlag "xft" (xorg != null) null)
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
      x86_64-linux;
  };
}
