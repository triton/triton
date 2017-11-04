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

  version = "1.7.4";
in
buildPythonPackage rec {
  name = "pylint-${version}";

  src = fetchPyPi {
    package = "pylint";
    inherit version;
    sha256 = "1f65b3815c3bf7524b845711d54c4242e4057dd93826586620239ecdfe591fb1";
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
