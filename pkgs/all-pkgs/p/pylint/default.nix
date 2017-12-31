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

  version = "1.8.1";
in
buildPythonPackage rec {
  name = "pylint-${version}";

  src = fetchPyPi {
    package = "pylint";
    inherit version;
    sha256 = "3035e44e37cd09919e9edad5573af01d7c6b9c52a0ebb4781185ae7ab690458b";
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
