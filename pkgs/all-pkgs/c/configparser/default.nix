{ stdenv
, buildPythonPackage
, fetchPyPi
, isPy3
, lib
}:

let
  version = "3.7.1";
in
buildPythonPackage rec {
  name = "configparser-${version}";

  src = fetchPyPi {
    package = "configparser";
    inherit version;
    sha256 = "5bd5fa2a491dc3cfe920a3f2a107510d65eceae10e9c6e547b90261a4710df32";
  };

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
