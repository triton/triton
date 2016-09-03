{ stdenv
, fetchurl

, glib
, libsigcxx
}:

stdenv.mkDerivation rec {
  name = "glibmm-${version}";
  versionMajor = "2.48";
  versionMinor = "1";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome-insecure/sources/glibmm/${versionMajor}/${name}.tar.xz";
    sha256Url = "mirror://gnome-secure/sources/glibmm/${versionMajor}/${name}.sha256sum";
    sha256 = "dc225f7d2f466479766332483ea78f82dc349d59399d30c00de50e5073157cdf";
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
