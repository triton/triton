{ stdenv
, buildPythonPackage
, cython
, fetchPyPi
, lib
}:

let
  version = "0.15.35";
in
buildPythonPackage {
  name = "ruamel.yaml-${version}";

  src = fetchPyPi {
    package = "ruamel.yaml";
    inherit version;
    sha256 = "8dc74821e4bb6b21fb1ab35964e159391d99ee44981d07d57bf96e2395f3ef75";
  };

  nativeBuildInputs = [
    cython
  ];

  preBuild = /* Force file to be generated with current cython */ ''
    pushd ext/
      rm _ruamel_yaml.c
      cython --verbose *.pyx
    popd
  '';

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
