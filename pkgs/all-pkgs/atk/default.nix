{ stdenv
, gettext
, fetchurl
, perl

, glib
, gobject-introspection
}:

with {
  inherit (stdenv.lib)
    enFlag;
};

stdenv.mkDerivation rec {
  name = "atk-${version}";
  versionMajor = "2.20";
  versionMinor = "0";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/atk/${versionMajor}/${name}.tar.xz";
    sha256 = "493a50f6c4a025f588d380a551ec277e070b28a82e63ef8e3c06b3ee7c1238f0";
  };

  nativeBuildInputs = [
    gettext
    perl
  ];

  buildInputs = [
    glib
    gobject-introspection
  ];

  configureFlags = [
    "--enable-rebuilds"
    "--enable-glibtest"
    (enFlag "introspection" (gobject-introspection != null) null)
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
  ];

  postInstall = "rm -rvf $out/share/gtk-doc";

  meta = with stdenv.lib; {
    description = "GTK+ & GNOME Accessibility Toolkit";
    homepage = http://library.gnome.org/devel/atk/;
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
