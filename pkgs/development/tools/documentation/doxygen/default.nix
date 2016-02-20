{ stdenv, fetchurl, perl, python, flex, bison, qt4 }:

let
  name = "doxygen-1.8.6";
in
stdenv.mkDerivation {
  inherit name;

  src = fetchurl {
    url = "ftp://ftp.stack.nl/pub/users/dimitri/${name}.src.tar.gz";
    sha256 = "0pskjlkbj76m9ka7zi66yj8ffjcv821izv3qxqyyphf0y0jqcwba";
  };

  prePatch = ''
    substituteInPlace configure --replace /usr/bin/install $(type -P install)
  '';

  patches = [ ./tmake.patch ];

  buildInputs =
    [ perl python flex bison ]
    ++ stdenv.lib.optional (qt4 != null) qt4;

  prefixKey = "--prefix ";

  configureFlags =
    [ "--dot dot" ]
    ++ stdenv.lib.optional (qt4 != null) "--with-doxywizard";

  preConfigure =
    ''
      patchShebangs .
    '' + stdenv.lib.optionalString (qt4 != null)
    ''
      echo "using QTDIR=${qt4}..."
      export QTDIR=${qt4}
    '';

  makeFlags = "MAN1DIR=share/man/man1";

  meta = {
    license = stdenv.lib.licenses.gpl2Plus;
    homepage = "http://doxygen.org/";
    description = "Source code documentation generator tool";
    maintainers = [ ];
    platforms = stdenv.lib.platforms.linux;
  };
}
