{ stdenv
, autoreconfHook
, fetchurl
, gtk-doc

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
  versionMajor = "1.38";
  versionMinor = "1";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/pango/${versionMajor}/${name}.tar.xz";
    sha256 = "1dsf45m51i4rcyvh5wlxxrjfhvn5b67d5ckjc6vdcxbddjgmc80k";
  };

  nativeBuildInputs = [
    autoreconfHook
    gtk-doc
  ];

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
      sed -i tests/Makefile.am \
        -e 's,test-pangocairo-threads,,'
    '';

  preAutoreconf = ''
    gtkdocize
  '';

  configureFlags = [
    "--enable-rebuilds"
    (enFlag "introspection" (gobject-introspection != null) null)
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--disable-doc-cross-reference"
    "--enable-Bsymbolic"
    "--enable-installed-tests"
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
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}
