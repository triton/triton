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
  versionMajor = "3.20";
  versionMinor = "0";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/pygobject/${versionMajor}/${name}.tar.xz";
    sha256 = "31ab4701f40490082aa98af537ccddba889577abe66d242582f28577e8807f46";
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
