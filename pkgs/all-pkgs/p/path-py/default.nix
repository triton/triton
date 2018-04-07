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
  version = "11.0.1";
in
buildPythonPackage rec {
  name = "path-py-${version}";

  src = fetchPyPi {
    package = "path.py";
    inherit version;
    sha256 = "e7eb9d0ca4110d9b4d7c9baa0696d8c94f837d622409cefc5ec9e7c3d02ea11f";
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
