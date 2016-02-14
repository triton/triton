{ stdenv
, fetchurl

, attr
, gettext
}:

stdenv.mkDerivation rec {
  name = "acl-2.2.52";

  src = fetchurl {
    url = "mirror://savannah/acl/${name}.src.tar.gz";
    sha256 = "08qd9s3wfhv0ajswsylnfwr5h0d7j9d4rgip855nrh400nxp940p";
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
    "ZIP=gzip"
  ];

  nativeBuildInputs = [
    gettext
  ];

  buildInputs = [
    attr
  ];

  postPatch = ''
    # Upstream use C++-style comments in C code. Remove them.
    # This comment breaks compilation with strict gcc flags are used.
    sed -e '/^\/\//d' -i include/acl.h
  '';

  installTargets = [
    "install"
    "install-lib"
    "install-dev"
  ];

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "Library and tools for manipulating access control lists";
    homepage = http://savannah.nongnu.org/projects/acl;
    license = licenses.lgpl21;
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
