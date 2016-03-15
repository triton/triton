{ stdenv
, fetchurl
, gettext
, intltool

, glib
, gobject-introspection
, vala
, zlib
}:

with {
  inherit (stdenv.lib)
    enFlag;
};

stdenv.mkDerivation rec {
  name = "gcab-${version}";
  version = "0.6";

  src = fetchurl {
    url = "mirror://gnome/sources/gcab/${version}/${name}.tar.xz";
    sha256 = "1frl2dpjz5qzqkhyp3qbjck6wsr5m6gdzz2v2nsjfwps9f83ni50";
  };

  nativeBuildInputs = [
    gettext
    intltool
  ];

  buildInputs = [
    glib
    gobject-introspection
    vala
    zlib
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    (enFlag "introspection" (gobject-introspection != null) null)
    "--enable-nls"
    "--enable-glibtest"
  ];

  meta = with stdenv.lib; {
    description = "Library and tool for Microsoft Cabinet (CAB) files";
    homepage = https://wiki.gnome.org/msitools;
    license = licenses.lgpl21Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };

}
