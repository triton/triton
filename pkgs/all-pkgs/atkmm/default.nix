{ stdenv
, fetchurl

, atk
, glibmm
}:

stdenv.mkDerivation rec {
  name = "atkmm-${version}";
  versionMajor = "2.24";
  versionMinor = "2";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/atkmm/${versionMajor}/${name}.tar.xz";
    sha256 = "1gaqwhviadsmy0fsr47686yglv1p4mpkamj0in127bz2b5bki5gz";
  };

  configureFlags = [
    "--enable-deprecated-api"
    "--disable-documentation"
    "--without-libstdc-doc"
    "--without-libsigc-doc"
    "--without-glibmm-doc"
  ];

  propagatedBuildInputs = [
    atk
    glibmm
  ];

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "C++ interface for the ATK library";
    homepage = http://www.gtkmm.org;
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
