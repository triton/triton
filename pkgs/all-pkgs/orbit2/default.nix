{ stdenv
, fetchurl

, glib
, libidl
}:

stdenv.mkDerivation rec {
  name = "ORBit2-${version}";
  versionMajor = "2.14";
  versionMinor = "19";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/ORBit2/${versionMajor}/${name}.tar.bz2";
    sha256 = "0l3mhpyym9m5iz09fz0rgiqxl2ym6kpkwpsp1xrr4aa80nlh1jam";
  };

  buildInputs = [
    glib
    libidl
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-compile-warnings"
    "--disable-debug"
    "--disable-purify"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
  ];

  preBuild = ''
    sed -i linc2/src/Makefile \
      -e 's/-DG_DISABLE_DEPRECATED//'
  '';

  parallelBuild = false;

  meta = with stdenv.lib; {
    description = "A a CORBA 2.4-compliant Object Request Broker";
    homepage = https://projects.gnome.org/ORBit2/;
    license = licenses.gpl2;
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
