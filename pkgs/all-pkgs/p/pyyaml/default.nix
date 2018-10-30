{ stdenv
, buildPythonPackage
, cython
, fetchPyPi
, lib

, libyaml
}:

let
  version = "3.13";
in
buildPythonPackage {
  name = "PyYAML-${version}";

  src = fetchPyPi {
    package = "PyYAML";
    inherit version;
    sha256 = "3ef3092145e9b70e3ddd2c7ad59bdd0252a94dfe3949721633e41344de00a6bf";
  };

  nativeBuildInputs = [
    cython
  ];

  buildInputs = [
    libyaml
  ];

  postPatch = /* Force files to be regenerated with the current cython */ ''
    rm ext/*.c || true
  '';

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
