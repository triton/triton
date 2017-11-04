{ stdenv
, buildPythonPackage
, fetchPyPi
, isPy3
, lib

, isort
, mccabe
, pytest-runner
, singledispatch
, six
}:

let
  version = "3.5.0";
in
buildPythonPackage rec {
  name = "configparser-${version}";

  src = fetchPyPi {
    package = "configparser";
    inherit version;
    sha256 = "5308b47021bc2340965c371f0f058cc6971a04502638d4244225c49d80db273a";
  };

  propagatedBuildInputs = [
    func
  ];

  disabled = isPy3;  # FIXME: < 3.5

  meta = with lib; {
    description = "Updated configparser from Python 3.5";
    homepage = https://pypi.python.org/pypi/configparser;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
