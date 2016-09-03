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
  versionMinor = "1";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/pangomm/${versionMajor}/${name}.tar.xz";
    sha256Url = "mirror://gnome/sources/pangomm/${versionMajor}/"
      + "${name}.sha256sum";
    sha256 = "9762ee2a2d5781be6797448d4dd2383ce14907159b30bc12bf6b08e7227be3af";
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
