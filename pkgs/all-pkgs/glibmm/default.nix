{ stdenv
, fetchurl

, glib
, libsigcxx
}:

stdenv.mkDerivation rec {
  name = "glibmm-${version}";
  versionMajor = "2.48";
  versionMinor = "0";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/glibmm/${versionMajor}/${name}.tar.xz";
    sha256 = "b531392b03a34b8d0bd86d8a70510e7812fccfad47bd43eeff9e8a16d8438b85";
  };

  buildInputs = [
    glib
    libsigcxx
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-schemas-compile"
    "--disable-documentation"
    "--disable-debug-refcounting"
    "--enable-warnings"
    # Deprecated apis used by gtkmm2
    "--enable-deprecated-api"
    "--without-libstdc-doc"
    "--without-libsigc-doc"
  ];

  meta = with stdenv.lib; {
    description = "C++ interface to the GLib library";
    homepage = http://gtkmm.org/;
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
