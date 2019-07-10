{ stdenv
, buildPythonPackage
, fetchPyPi
, isPy2
, lib

, astroid
, isort
, mccabe
, pytest-runner
, six
}:

let
  inherit (lib)
    optionals;

  version = "1.8.4";
in
buildPythonPackage rec {
  name = "pylint-${version}";

  src = fetchPyPi {
    package = "pylint";
    inherit version;
    sha256 = "34738a82ab33cbd3bb6cd4cef823dbcabdd2b6b48a4e3a3054a2bbbf0c712be9";
  };

  propagatedBuildInputs = [
    astroid
    isort
    mccabe
    pytest-runner
    six
  ];

  meta = with lib; {
    description = "Source code analyzer";
    homepage = https://github.com/PyCQA/pylint;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
