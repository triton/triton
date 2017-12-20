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

  version = "1.8.0";
in
buildPythonPackage rec {
  name = "pylint-${version}";

  src = fetchPyPi {
    package = "pylint";
    inherit version;
    sha256 = "d24f38e876a88e8aa1efccc65af78cafcc790c2f561f49d30b91192af6ab6086";
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
