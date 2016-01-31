{ stdenv
, fetchurl
, gettext
, intltool

, glib
, gnome-backgrounds
, gobject-introspection
}:

with {
  inherit (stdenv.lib)
    enFlag;
};

stdenv.mkDerivation rec {
  name = "gsettings-desktop-schemas-${version}";
  versionMajor = "3.18";
  versionMinor = "1";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/gsettings-desktop-schemas/${versionMajor}/${name}.tar.xz";
    sha256 = "06lsz789q3g4zdgzbqk0gn1ak3npk0gwikqvjy86asywlfr171r5";
  };

  nativeBuildInputs = [
    gettext
    intltool
  ];

  buildInputs = [
    glib
    gobject-introspection
  ];

  postPatch = ''
    sed -i schemas/org.gnome.desktop.{background,screensaver}.gschema.xml.in \
      -e 's|@datadir@|${gnome-backgrounds}/share/|'
  '';

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-schemas-compile"
    (enFlag "introspection" (gobject-introspection != null) null)
    "--enable-nls"
  ];

  meta = with stdenv.lib; {
    description = "Collection of GSettings schemas for GNOME desktop";
    homepage = https://git.gnome.org/browse/gsettings-desktop-schemas;
    license = licenses.lgpl21Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}
