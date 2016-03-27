{ stdenv
, autoreconfHook
, bison
, fetchurl
, flex
, gettext
, libxslt

, glib
, gobject-introspection
}:

stdenv.mkDerivation rec {
  name = "vala-${version}";
  versionMajor = "0.32";
  versionMinor = "0";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/vala/${versionMajor}/${name}.tar.xz";
    sha256 = "07a2aa4ede040789b4b5af817a42249d703bfe8affccb7732ca2b53d00c1fb6e";
  };

  nativeBuildInputs = [
    autoreconfHook
    bison
    flex
    gettext
    libxslt
  ];

  buildInputs = [
    glib
    gobject-introspection
  ];

  setupHook = ./setup-hook.sh;

  postPatch = ''
    patchShebangs ./tests/testrunner.sh
  '' + /* dbus tests require machine-id */ ''
    sed -i tests/Makefile.am \
      -e '/dbus\//d'
  '';

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-unversioned"
    "--disable-coverage"
  ];

  doCheck = true;

  meta = with stdenv.lib; {
    description = "Compiler for GObject type system";
    homepage = "http://live.gnome.org/Vala";
    license = licenses.lgpl21Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
