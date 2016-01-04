{ stdenv
, fetchurl

, cairo
, fontconfig
, freetype
, glib
, gobject-introspection
, harfbuzz
, libpng
, xorg
#, LibThai
}:

with {
  inherit (stdenv.lib)
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

  configureFlags = [
    "--enable-rebuilds"
    "--enable-introspection"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--disable-doc-cross-reference"
    "--enable-Bsymbolic"
    "--enable-installed-tests"
    (wtFlag "xft" (xorg.libXft != null) null)
    (wtFlag "cairo" (cairo != null) null)
  ];

  buildInputs = [
    cairo
    fontconfig
    freetype
    glib
    gobject-introspection
    harfbuzz
    libpng
    xorg.libX11
    xorg.libXft
    xorg.libXrender
  ];

  postInstall = "rm -rvf $out/share/gtk-doc";

  preCheck = optionalString doCheck ''
    # Fontconfig fails to load default config in test
    export FONTCONFIG_FILE="${fontconfig}/etc/fonts/fonts.conf"
  '';

  doCheck = true;
  enableParallelBuilding = true;

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
