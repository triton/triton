{ stdenv
, fetchurl

, cairomm
, glibmm
, libpng
, pango
}:

stdenv.mkDerivation rec {
  name = "pangomm-${version}";
  versionMajor = "2.40";
  versionMinor = "0";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/pangomm/${versionMajor}/${name}.tar.xz";
    sha256 = "7dd0afa9dcce57cdb0aad77da9ea46823ee8515d5f3ffd895b9ede7365c3d70d";
  };

  buildInputs = [
    cairomm
    glibmm
    libpng
    pango
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--disable-deprecated-api"
    "--disable-documentation"
    "--enable-warnings"
    "--without-libstdc-doc"
    "--without-libsigc-doc"
    "--without-glibmm-doc"
    "--without-cairomm-doc"
  ];

  meta = with stdenv.lib; {
    description = "C++ interface to the Pango text rendering library";
    homepage = http://www.pango.org/;
    license = with licenses; [
      lgpl2
      lgpl21
    ];
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
