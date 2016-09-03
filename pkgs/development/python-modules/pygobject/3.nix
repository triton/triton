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
  versionMinor = "1";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome-insecure/sources/pygobject/${versionMajor}/${name}.tar.xz";
    sha256 = "3d261005d6fed6a92ac4c25f283792552f7dad865d1b7e0c03c2b84c04dbd745";
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
