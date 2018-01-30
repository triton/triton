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

let
  inherit (lib)
    optionals;

  version = "1.8.2";
in
buildPythonPackage rec {
  name = "pylint-${version}";

  src = fetchPyPi {
    package = "pylint";
    inherit version;
    sha256 = "4fe3b99da7e789545327b75548cee6b511e4faa98afe268130fea1af4b5ec022";
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
