{ stdenv
, fetchurl
, intltool

, glib
, gnome-backgrounds
, gobject-introspection
}:

stdenv.mkDerivation rec {
  name = "gsettings-desktop-schemas-${version}";
  versionMajor = "3.18";
  versionMinor = "1";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/gsettings-desktop-schemas/${versionMajor}/${name}.tar.xz";
    sha256 = "06lsz789q3g4zdgzbqk0gn1ak3npk0gwikqvjy86asywlfr171r5";
  };

  postPatch = ''
    for file in "background" "screensaver" ; do
      substituteInPlace "schemas/org.gnome.desktop.$file.gschema.xml.in" \
        --replace "@datadir@" "${gnome-backgrounds}/share/"
    done
  '';

  nativeBuildInputs = [
    intltool
  ];

  buildInputs = [
    glib
    gobject-introspection
  ];

  meta = with stdenv.lib; {
    #maintainers = gnome3.maintainers;
  };
}
