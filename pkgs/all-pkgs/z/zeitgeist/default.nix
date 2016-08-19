{ stdenv
, automake
, fetchTritonPatch
, fetchurl
, intltool

, dbus
, dbus-glib
, glib
, gobject-introspection
, gtk3
, json-glib
, python
, pythonPackages
, raptor2
, sqlite
, telepathy_glib
, vala
}:

let
  inherit (stdenv.lib)
    boolEn;

  versionMajor = "0.9";
  versionMinor = "16";
  version = "${versionMajor}.${versionMinor}";
in
stdenv.mkDerivation rec {
  name = "zeitgeist-${version}";

  src = fetchurl {
    url = "https://launchpad.net/zeitgeist/${versionMajor}/${version}/"
      + "+download/${name}.tar.xz";
    sha256 = "0fkxjbqcpnjmhy2g6xqryyq0xhgsrbn9ph9lw67aabnq1h6ydlvf";
  };

  nativeBuildInputs = [
    automake
    intltool
  ];

  buildInputs = [
    dbus
    dbus-glib
    glib
    gobject-introspection
    gtk3
    json-glib
    python
    pythonPackages.rdflib
    raptor2
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

  preConfigure = ''
    configureFlagsArray+=(
      "--with-session-bus-services-dir=$out/share/dbus-1/services"
    )
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
    "--${boolEn (gobject-introspection != null)}-introspection"
  ];

  meta = with stdenv.lib; {
    description = "A service which logs the users's activities and events";
    homepage = https://launchpad.net/zeitgeist;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
