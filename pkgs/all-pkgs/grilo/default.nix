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

with {
  inherit (stdenv.lib)
    enFlag;
};

stdenv.mkDerivation rec {
  name = "grilo-${version}";
  versionMajor = "0.2";
  versionMinor = "15";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/grilo/${versionMajor}/${name}.tar.xz";
    sha256 = "05b8sqfmywg45b9frya6xmw5l3c8vf5a1nhy51nyfs0a4n1japbg";
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
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}
