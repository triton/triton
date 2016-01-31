{ stdenv
, autoreconfHook
, bison
, fetchurl
, flex
, gettext
, libxslt

, glib
, gobject-introspection
, libiconv
}:

stdenv.mkDerivation rec {
  name = "vala-${version}";
  versionMajor = "0.30";
  versionMinor = "0";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/vala/${versionMajor}/${name}.tar.xz";
    sha256 = "1pyyhfw3zzbhxfscbn8xz70dg6vx0kh8gshzikpxczhg01xk7w31";
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
    libiconv
  ];

  postPatch = ''
    patchShebangs ./tests/testrunner.sh
  '' +
  /* dbus tests require machine-id */ ''
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
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}
