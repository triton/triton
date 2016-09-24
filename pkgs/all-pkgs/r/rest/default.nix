{ stdenv
, fetchurl
, intltool

, glib
, gobject-introspection
, libsoup
, libxml2
}:

let
  inherit (stdenv.lib)
    enFlag
    wtFlag;
in

stdenv.mkDerivation rec {
  name = "rest-${version}";
  versionMajor = "0.8";
  versionMinor = "0";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/rest/${versionMajor}/${name}.tar.xz";
    sha256 = "e7b89b200c1417073aef739e8a27ff2ab578056c27796ec74f5886a5e0dff647";
  };

  nativeBuildInputs = [
    intltool
  ];

  buildInputs = [
    glib
    gobject-introspection
    libsoup
    libxml2
  ];

  configureFlags = [
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    (enFlag "introspection" (gobject-introspection != null) "yes")
    "--disable-gcov"
    # gnome support only adds a dependency on obsolete libsoup-gnome
    "--without-gnome"
    "--with-ca-certificates=/etc/ssl/certs/ca-certificates.crt"
  ];

  postInstall = "rm -rvf $out/share/gtk-doc";

  meta = with stdenv.lib; {
    description = "Helper library for RESTful services";
    homepage = https://wiki.gnome.org/Projects/Librest;
    license = licenses.lgpl21;
    maintainers = with maintainers;[
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
