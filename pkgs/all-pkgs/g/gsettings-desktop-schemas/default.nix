{ stdenv
, fetchurl
, gettext
, intltool

, glib
, gnome-backgrounds
, gobject-introspection
}:

let
  inherit (stdenv.lib)
    enFlag;
in

stdenv.mkDerivation rec {
  name = "gsettings-desktop-schemas-${version}";
  versionMajor = "3.20";
  versionMinor = "0";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome-insecure/sources/gsettings-desktop-schemas/${versionMajor}/${name}.tar.xz";
    sha256 = "55a41b533c0ab955e0a36a84d73829451c88b027d8d719955d8f695c35c6d9c1";
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
    platforms = with platforms;
      x86_64-linux;
  };
}
