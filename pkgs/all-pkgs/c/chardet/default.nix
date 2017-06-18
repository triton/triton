{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, pytest-runner
}:

let
  version = "3.0.4";
in
buildPythonPackage rec {
  name = "chardet-${version}";

  src = fetchPyPi {
    package = "chardet";
    inherit version;
    sha256 = "84ab92ed1c4d4f16916e05906b6b75a6c0fb5db821cc65e70cbd64a3e2a5eaae";
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
