{ stdenv
, fetchurl
, gettext
}:

stdenv.mkDerivation rec {
  name = "attr-2.4.47";

  src = fetchurl {
    url = "mirror://savannah/attr/${name}.src.tar.gz";
    sha256 = "0nd8y0m6awc9ahv0ciiwf8gy54c8d3j51pw9xg7f7cn579jjyxr5";
  };

  configureFlags = [
    "--enable-gettext"
    "--disable-lib64"
    "AWK=gawk"
    "ECHO=exho"
    "MAKE=make"
    "MSGFMT=msgfmt"
    "MSGMERGE=msgmerge"
    "SED=sed"
    "XGETTEXT=xgettext"
  ];

  nativeBuildInputs = [
    gettext
  ];

  installTargets = [
    "install"
    "install-lib"
    "install-dev"
  ];

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "Library and tools for manipulating extended attributes";
    homepage = http://savannah.nongnu.org/projects/attr/;
    license = licenses.lgpl21;
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
