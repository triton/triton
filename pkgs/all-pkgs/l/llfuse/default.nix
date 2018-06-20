{ stdenv
, buildPythonPackage
, cython
, fetchPyPi
, lib
, python

, attr
, fuse_2
}:

let
  version = "1.3.4";
in
buildPythonPackage {
  name = "llfuse-${version}";

  src = fetchPyPi {
    package = "llfuse";
    inherit version;
    type = ".tar.bz2";
    sha256 = "50396c5f3c49c3145e696e5b62df4fcca8b66634788020fba7b6932a858c78c2";
  };

  nativeBuildInputs = [
    cython
  ];

  buildInputs = [
    attr
    fuse_2
  ];

  postPatch = /* Force cython to re-generate files */ ''
    rm src/llfuse.c
  '' + ''
    sed -i setup.py \
      -e '/-Werror=conversion/d'

    grep -q '<attr/xattr.h>' src/xattr.h
    sed \
      -e 's,attr/xattr.h,sys/xattr.h,g' \
      -e '\#sys/xattr.h#a#include <attr/attributes.h>' \
      -i src/xattr.h
  '';

  preBuild = ''
    ${python.interpreter} setup.py build_cython
  '';

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
