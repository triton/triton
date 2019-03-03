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
  version = "1.3.6";
in
buildPythonPackage {
  name = "llfuse-${version}";

  src = fetchPyPi {
    package = "llfuse";
    inherit version;
    type = ".tar.bz2";
    sha256 = "31a267f7ec542b0cd62e0f1268e1880fdabf3f418ec9447def99acfa6eff2ec9";
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
