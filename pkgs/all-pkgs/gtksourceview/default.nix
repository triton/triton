{ stdenv
, fetchTritonPatch
, fetchurl
, gettext
, intltool

, atk
, cairo
, gdk-pixbuf
, glib
, gtk3
, pango
, libxml2
, perl
, gobject-introspection
, vala
}:

with {
  inherit (stdenv.lib)
    enFlag;
};

stdenv.mkDerivation rec {
  name = "gtksourceview-${version}";
  versionMajor = "3.20";
  versionMinor = "0";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/gtksourceview/${versionMajor}/${name}.tar.xz";
    sha256 = "0b753cbd49cdfb0fb8bb347e4669dcc233d9c05c1d321429efe93c4e885262fd";
  };

  patches = [
    (fetchTritonPatch {
      rev = "453aedffa95d1c459a15a6f1fb8cb9d0ce810803";
      file = "gtksourceview/nix_share_path.patch";
      sha256 = "522655ce1664afef805040f2068094fdf57e3283a4cc2bdf52b33cb6de9fbe00";
    })
  ];

  nativeBuildInputs = [
    gettext
    intltool
  ];

  buildInputs = [
    atk
    cairo
    gdk-pixbuf
    glib
    gtk3
    pango
    libxml2
    perl
    gobject-introspection
    vala
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-compile-warnings"
    "--enable-Werror"
    "--enable-deprecations"
    "--enable-completion-providers"
    "--disable-glade-catalog"
    "--enable-nls"
    "--enable-rpath"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--disable-installed-tests"
    (enFlag "introspection" (gobject-introspection != null) null)
    "--disable-code-coverage"
    (enFlag "vala" (vala != null) null)
  ];

  preBuild = ''
    substituteInPlace gtksourceview/gtksourceview-utils.c \
      --replace "@NIX_SHARE_PATH@" "$out/share"
  '';

  meta = with stdenv.lib; {
    description = "A text widget for syntax highlighting and other features";
    homepage = https://wiki.gnome.org/Projects/GtkSourceView;
    license = with licenses; [
      gpl2Plus
      lgpl21Plus
    ];
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
