{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, glibcLocales
, pytest
, pytest-runner
, setuptools-scm
}:

let
  version = "10.3.1";
in
buildPythonPackage rec {
  name = "path.py-${version}";

  src = fetchPyPi {
    package = "path.py";
    inherit version;
    sha256 = "412706be1cd8ab723c77829f9aa0c4d4b7c7b26c7b1be0275a6841c3cb1001e0";
  };

  buildInputs = [
    glibcLocales
    pytest
    pytest-runner
    setuptools-scm
  ];

  LC_ALL = "en_US.UTF-8";

  checkPhase = ''
    py.test test_path.py
  '';

  meta = with lib; {
    description = "A module wrapper for os.path";
    homepage = http://github.com/jaraco/path.py;
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      x86_64-linux;
  };
}
