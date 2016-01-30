{ stdenv
, fetchurl

, glib
, gobject-introspection
, libsoup
, libxml2
}:

with {
  inherit (stdenv.lib)
    enFlag;
};

stdenv.mkDerivation rec {
  name = "rest-${version}";
  versionMajor = "0.7";
  versionMinor = "93";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/rest/${versionMajor}/${name}.tar.xz";
    sha256 = "05mj10hhiik23ai8w4wkk5vhsp7hcv24bih5q3fl82ilam268467";
  };

  buildInputs = [
    glib
    gobject-introspection
    libsoup
    libxml2
  ];

  configureFlags = [
    (enFlag "introspection" (gobject-introspection != null) "yes")
    "--with-gnome"
    "--with-ca-certificates=/etc/ssl/certs/ca-certificates.crt"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
  ];

  postInstall = "rm -rvf $out/share/gtk-doc";

  meta = with stdenv.lib; {
    description = "Helper library for RESTful services";
    homepage = https://wiki.gnome.org/Projects/Librest;
    license = licenses.lgpl21;
    maintainers = with maintainers;[
      codyopel
    ];
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}
