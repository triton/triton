{ stdenv
, fetchurl
, file
, gettext
, intltool

, glib
, gobject-introspection
, liboauth
, libsoup
, libxml2
, totem-pl-parser
, vala
}:

let
  inherit (stdenv.lib)
    enFlag;
in

stdenv.mkDerivation rec {
  name = "grilo-${version}";
  versionMajor = "0.3";
  versionMinor = "0";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/grilo/${versionMajor}/${name}.tar.xz";
    sha256 = "1fd1a87d606f56adb3086954baec3ea6e25d9ba3fb010f11d1d3ddc9ec66bc60";
  };

  nativeBuildInputs = [
    file
    gettext
    intltool
  ];

  buildInputs = [
    glib
    gobject-introspection
    liboauth
    libsoup
    libxml2
    totem-pl-parser
    vala
  ];

  setupHook = ./setup-hook.sh;

  configureFlags = [
    "--enable-compile-warnings"
    "--disable-iso-c"
    "--disable-maintainer-mode"
    "--disable-test-ui"
    "--enable-grl-net"
    (enFlag "grl-pls" (totem-pl-parser != null) null)
    "--disable-debug"
    # Flag is not a boolean
    #"--disable-tests"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    (enFlag "introspection" (gobject-introspection != null) null)
    (enFlag "vala" (vala != null) null)
    "--enable-nls"
  ];

  meta = with stdenv.lib; {
    description = "A framework for easy media discovery and browsing";
    homepage = https://wiki.gnome.org/Projects/Grilo;
    license = licenses.lgpl21Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
