{ stdenv
, fetchurl

, atkmm
, cairomm
, glibmm
, gtk2
, pangomm
}:

with {
  inherit (stdenv.lib)
    enFlag;
};

stdenv.mkDerivation rec {
  name = "gtkmm-${version}";
  versionMajor = "2.24";
  versionMinor = "4";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/gtkmm/${versionMajor}/${name}.tar.xz";
    sha256 = "1vpmjqv0aqb1ds0xi6nigxnhlr0c74090xzi15b92amlzkrjyfj4";
  };

  patches = [
    ./gtkmm-2.24.4-papersize.patch
    ./gtkmm-2.24.4-missing-includes.patch
    ./gtkmm-2.24.4-newer-glibmm.patch
    ./gtkmm-2.24.4-add-list.m4.patch
    ./gtkmm-2.24.4-fix-add-list.m4.patch
    ./gtkmm-2.24.4-cpp11.patch
    ./gtkmm-2.24.4-gdkpixbud-deprecation-warnings.patch
  ];

  configureFlags = [
    (enFlag "api-atkmm" (atkmm != null) null)
    # Nokia maemo
    (enFlag "api-maemo-extensions" true null)
    # Requires deprecated api
    "--enable-deprecated-api"
    "--disable-documentation"
    "--without-libstdc-doc"
    "--without-libsigc-doc"
    "--without-glibmm-doc"
    "--without-cairomm-doc"
    "--without-pangomm-doc"
    "--without-atkmm-doc"
  ];

  propagatedBuildInputs = [
    atkmm
    cairomm
    glibmm
    gtk2
    pangomm
  ];

  doCheck = true;
  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "C++ interface for GTK+";
    homepage = http://gtkmm.org/;
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}
