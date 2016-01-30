{ stdenv
, fetchurl
, intltool

, libxml2
, gcr
, glib
, json-glib
, gnome-online-accounts
, gobject-introspection
, liboauth
, libsoup
, openssl
, p11_kit
, vala
}:

with {
  inherit (stdenv.lib)
    enFlag;
};

stdenv.mkDerivation rec {
  name = "libgdata-${version}";
  versionMajor = "0.17";
  versionMinor = "4";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/libgdata/${versionMajor}/${name}.tar.xz";
    sha256 = "1xniw4y90hbk9fa548pa9pfclibw7amr2f458lfh16jdzq7gw5cz";
  };

  nativeBuildInputs = [
    intltool
  ];

  buildInputs = [
    gcr
    glib
    gnome-online-accounts
    gobject-introspection
    json-glib
    liboauth
    libsoup
    libxml2
    openssl
    p11_kit
    vala
  ];

  configureFlags = [
    "--enable-gnome"
    (enFlag "goa" (gnome-online-accounts != null) null)
    "--disable-always-build-tests"
    "--disable-installed-tests"
    "--enable-nls"
    "--disable-code-coverage"
    "--enable-compile-warnings"
    "--disable-Werror"
    (enFlag "introspection" (gobject-introspection != null) null)
    (enFlag "vala" (vala != null) null)
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
  ];

  NIX_CFLAGS_COMPILE = [
    "-I${libsoup}/include/libsoup-gnome-2.4/"
    "-I${gcr}/include/gcr-3"
    "-I${gcr}/include/gck-1"
  ];

  meta = with stdenv.lib; {
    description = "GLib library for online service APIs using the GData protocol";
    homepage = https://wiki.gnome.org/Projects/libgdata;
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
