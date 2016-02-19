{ stdenv
, bison
, fetchurl
, flex
, gettext

, glib
}:

stdenv.mkDerivation rec {
  name = "libIDL-${version}";
  versionMajor = "0.8";
  versionMinor = "14";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/libIDL/${versionMajor}/${name}.tar.bz2";
    sha256 = "08129my8s9fbrk0vqvnmx6ph4nid744g5vbwphzkaik51664vln5";
  };

  nativeBuildInputs = [
    bison
    flex
    gettext
  ];

  buildInputs = [
    glib
  ];

  configureFlags = [
    "--disable-compile-warnings"
    "--disable-maintainer-mode"
  ];

  meta = with stdenv.lib; {
    description = "CORBA tree builder";
    homepage = https://projects.gnome.org/ORBit2/;
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
