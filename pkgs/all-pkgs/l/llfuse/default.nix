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
  version = "1.3.3";
in
buildPythonPackage {
  name = "llfuse-${version}";

  src = fetchPyPi {
    package = "llfuse";
    inherit version;
    type = ".tar.bz2";
    sha256 = "e514fa390d143530c7395f640c6b527f4f80b03f90995c7b38ff0b2f86e11ce7";
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
