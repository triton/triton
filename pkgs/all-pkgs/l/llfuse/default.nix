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
  version = "1.3.5";
in
buildPythonPackage {
  name = "llfuse-${version}";

  src = fetchPyPi {
    package = "llfuse";
    inherit version;
    type = ".tar.bz2";
    sha256 = "6e412a3d9be69162d49b8a4d6fb3c343d1c1fba847f4535d229e0ece2548ead8";
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
