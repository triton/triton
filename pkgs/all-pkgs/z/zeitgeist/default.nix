{ stdenv
, automake
, fetchTritonPatch
, fetchurl
, intltool
, lib

, dbus
, dbus-glib
, glib
, gobject-introspection
, gtk3
, json-glib
, pythonPackages
, raptor2
, sqlite
, telepathy_glib
, vala
}:

let
  inherit (stdenv.lib)
    boolEn;

  channel = "1.0";
  version = "${channel}.1";
in
stdenv.mkDerivation rec {
  name = "zeitgeist-${version}";

  src = fetchurl {
    url = "https://launchpad.net/zeitgeist/${channel}/${version}/"
      + "+download/${name}.tar.xz";
    sha256 = "7de6a8e7b8aed33490437e522a9bf2e531681118c8cd91c052d554bbe64435bd";
  };

  nativeBuildInputs = [
    automake
    intltool
    vala
  ];

  buildInputs = [
    dbus
    dbus-glib
    glib
    gobject-introspection
    gtk3
    json-glib
    pythonPackages.python
    pythonPackages.rdflib
    raptor2
    sqlite
    telepathy_glib
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

  meta = with lib; {
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
