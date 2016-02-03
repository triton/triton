{ stdenv
, fetchurl
, gettext
, intltool

, glib
, gnome-online-accounts
, gobject-introspection
, gtk3
, json-glib
, libsoup
, rest
}:

with {
  inherit (stdenv.lib)
    enFlag;
};

stdenv.mkDerivation rec {
  name = "libzapojit-${version}";
  versionMajor = "0.0";
  versionMinor = "3";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/libzapojit/${versionMajor}/${name}.tar.xz";
    sha256 = "0zn3s7ryjc3k1abj4k55dr2na844l451nrg9s6cvnnhh569zj99x";
  };

  nativeBuildInputs = [
    gettext
    intltool
  ];

  buildInputs = [
    glib
    gnome-online-accounts
    gobject-introspection
    gtk3
    json-glib
    libsoup
    rest
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--disable-debug"
    (enFlag "introspection" (gobject-introspection != null) null)
    "--enable-nls"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
  ];

  meta = with stdenv.lib; {
    description = "GLib/GObject wrapper for SkyDrive and Hotmail REST APIs";
    homepage = https://git.gnome.org/browse/libzapojit;
    license = licenses.lgpl21;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}
