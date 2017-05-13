{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, pytest-runner
}:

let
  version = "3.0.2";
in
buildPythonPackage rec {
  name = "chardet-${version}";

  src = fetchPyPi {
    package = "chardet";
    inherit version;
    sha256 = "4f7832e7c583348a9eddd927ee8514b3bf717c061f57b21dbe7697211454d9bb";
  };

  propagatedBuildInputs = [
    pytest-runner
  ];

  doCheck = false;

  meta = with lib; {
    description = "Universal encoding detector";
    homepage = https://github.com/chardet/chardet;
    license = licenses.lgpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
