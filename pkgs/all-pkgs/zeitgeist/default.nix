{ stdenv
, automake114x
, fetchTritonPatch
, fetchurl
, intltool

, dbus_glib
, dbus_libs
, glib
, gobject-introspection
, gtk3
, json-glib
, librdf_raptor2
, python
, pythonPackages
, sqlite
, telepathy_glib
, vala
}:

with {
  inherit (stdenv.lib)
    enFlag;
};

stdenv.mkDerivation rec {
  name = "zeitgeist-${version}";
  versionMajor = "0.9";
  versionMinor = "16";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "https://launchpad.net/zeitgeist/${versionMajor}/${version}/" +
          "+download/${name}.tar.xz";
    sha256 = "0fkxjbqcpnjmhy2g6xqryyq0xhgsrbn9ph9lw67aabnq1h6ydlvf";
  };

  nativeBuildInputs = [
    automake114x
    intltool
  ];

  buildInputs = [
    dbus_glib
    dbus_libs
    glib
    gobject-introspection
    gtk3
    json-glib
    librdf_raptor2
    python
    pythonPackages.rdflib
    sqlite
    telepathy_glib
    vala
  ];

  patches = [
    (fetchTritonPatch {
      rev = "d2c7f93cc1ef7d67c1d4218b3e9c761379bfb546";
      file = "zeitgeist/dbus_glib.patch";
      sha256 = "854d366bfcca0898ebebedf8e2e224e9f11abbcab40b8447da351c42dd728aad";
    })
  ];

  postPatch = ''
    patchShebangs ./data/ontology2code
  '';

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-nls"
    "--disable-explain-queries"
    # Requires: xapian-config
    #"--enable-fts"
    "--enable-datahub"
    "--enable-telepathy"
    "--enable-downloads-monitor"
    "--disable-docs"
    (enFlag "introspection" (gobject-introspection != null) null)
    "--with-session-bus-services-dir=$(out)/share/dbus-1/services"
  ];

  meta = with stdenv.lib; {
    description = "A service which logs the users's activities and events";
    homepage = https://launchpad.net/zeitgeist;
    license = licenses.gpl2;
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
