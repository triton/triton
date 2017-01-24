{ stdenv
, fetchurl
, intltool

, libxml2
, gcr
, glib
, json-glib
#, gnome-online-accounts
, gobject-introspection
, liboauth
, libsoup
, openssl
, p11-kit
, vala
}:

let
  inherit (stdenv.lib)
    enFlag;
in
stdenv.mkDerivation rec {
  name = "libgdata-${version}";
  versionMajor = "0.17";
  versionMinor = "6";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/libgdata/${versionMajor}/${name}.tar.xz";
    sha256 = "8b6a3ff1db23bd9e5ebbcc958b29b769a898f892eed4798222d562ba69df30b0";
  };

  nativeBuildInputs = [
    intltool
  ];

  buildInputs = [
    gcr
    glib
    #gnome-online-accounts
    gobject-introspection
    json-glib
    liboauth
    libsoup
    libxml2
    openssl
    p11-kit
    vala
  ];

  configureFlags = [
    "--enable-gnome"
    # Remove dependency on webkit
    #(enFlag "goa" (gnome-online-accounts != null) null)
    "--disable-goa"
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

  meta = with stdenv.lib; {
    description = "GLib library for online service APIs using the GData protocol";
    homepage = https://wiki.gnome.org/Projects/libgdata;
    license = licenses.lgpl21Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };

}
