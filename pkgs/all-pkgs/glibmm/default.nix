{ stdenv
, fetchurl

, glib
, libsigcxx
}:

stdenv.mkDerivation rec {
  name = "glibmm-${version}";
  versionMajor = "2.46";
  versionMinor = "3";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/glibmm/${versionMajor}/${name}.tar.xz";
    sha256 = "1kw65mlabwdjw86jybxslncbnnx40hcx4z6xpq9i4ymjvsnm91n7";
  };

  configureFlags = [
    "--enable-schemas-compile"
    "--disable-documentation"
    # Compile errors if deprecated api is not enabled
    "--enable-deprecated-api"
    "--without-libstdc-doc"
    "--without-libsigc-doc"
  ];

  propagatedBuildInputs = [
    glib
    libsigcxx
  ];

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "C++ interface to the GLib library";
    homepage = http://gtkmm.org/;
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
