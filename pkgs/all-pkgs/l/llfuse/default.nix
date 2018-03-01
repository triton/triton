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
  version = "1.3.2";
in
buildPythonPackage {
  name = "llfuse-${version}";

  src = fetchPyPi {
    package = "llfuse";
    inherit version;
    type = ".tar.bz2";
    sha256 = "96252a286a2be25810904d969b330ef2a57c2b9c18c5b503bbfbae40feb2bb63";
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
