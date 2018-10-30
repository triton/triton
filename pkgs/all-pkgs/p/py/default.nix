{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, setuptools-scm
}:

let
  version = "1.7.0";
in
buildPythonPackage rec {
  name = "py-${version}";

  src = fetchPyPi {
    package = "py";
    inherit version;
    sha256 = "bf92637198836372b520efcba9e020c330123be8ce527e535d185ed4b6f45694";
  };

  propagatedBuildInputs = [
    setuptools-scm
  ];

  doCheck = false;

  meta = with lib; {
    description = "Cross-python path, ini-parsing, io, code, log facilities";
    homepage = http://bitbucket.org/pytest-dev/py/;
    licenses = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
