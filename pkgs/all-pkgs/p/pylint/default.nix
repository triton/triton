{ stdenv
, buildPythonPackage
, fetchPyPi
, isPy2
, lib

, astroid
, configparser
, isort
, mccabe
, pytest-runner
, singledispatch
, six
}:

# FIXME: fix for python2

let
  inherit (lib)
    optionals;

  version = "1.7.5";
in
buildPythonPackage rec {
  name = "pylint-${version}";

  src = fetchPyPi {
    package = "pylint";
    inherit version;
    sha256 = "dd20d6f17e7ea9d3a3a35c5d56ba2c50fdfdb7192096a1095f1791d072bc59a1";
  };

  propagatedBuildInputs = [
    astroid
    isort
    mccabe
    pytest-runner
    singledispatch
    six
  ] ++ optionals isPy2 [  # FIXME: < 3.5
    configparser
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
