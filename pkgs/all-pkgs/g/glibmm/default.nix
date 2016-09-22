{ stdenv
, fetchurl

, glib
, libsigcxx
}:

stdenv.mkDerivation rec {
  name = "glibmm-${version}";
  versionMajor = "2.50";
  versionMinor = "0";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/glibmm/${versionMajor}/${name}.tar.xz";
    sha256Url = "mirror://gnome/sources/glibmm/${versionMajor}/${name}.sha256sum";
    sha256 = "df726e3c6ef42b7621474b03b644a2e40ec4eef94a1c5a932c1e740a78f95e94";
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
