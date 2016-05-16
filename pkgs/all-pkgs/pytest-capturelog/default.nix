{ stdenv
, buildPythonPackage
, fetchPyPi

, pythonPackages
}:

buildPythonPackage rec {
  name = "pytest-capturelog-${version}";
  version = "0.7";

  src = fetchPyPi {
    package = "pytest-capturelog";
    inherit version;
    sha256 = "b6e8d5189b39462109c2188e6b512d6cc7e66d62bb5be65389ed50e96d22000d";
  };

  buildInputs = [
    pythonPackages.py
  ];

  doCheck = true;

  meta = with stdenv.lib; {
    description = "py.test plugin to capture log messages";
    homepage = http://bitbucket.org/memedough/pytest-capturelog/;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
