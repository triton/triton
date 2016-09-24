{ stdenv
, fetchurl

, python
, pkgconfig
, glib
, gobject-introspection
, pycairo
, cairo
, libffi
}:

with {
  inherit (stdenv.lib)
    enFlag;
};

stdenv.mkDerivation rec {
  name = "pygobject-${version}";
  versionMajor = "3.22";
  versionMinor = "0";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/pygobject/${versionMajor}/${name}.tar.xz";
    sha256 = "08b29cfb08efc80f7a8630a2734dec65a99c1b59f1e5771c671d2e4ed8a5cbe7";
  };

  buildInputs = [
    cairo
    glib
    gobject-introspection
    libffi
    pycairo
    python
  ];

  configureFlags = [
    "--enable-thread"
    "--enable-glibtest"
    (enFlag "cairo" (cairo != null) null)
    "--enable-compile-warnings"
    "--disable-iso-c"
    "--disable-code-coverage"
    "--with-common"
  ];

  meta = with stdenv.lib; {
    description = "Python bindings for Glib";
    homepage = http://live.gnome.org/PyGObject;
    license = licenses.free;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
