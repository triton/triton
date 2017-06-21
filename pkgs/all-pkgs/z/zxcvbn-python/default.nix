{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "4.4.15";
in
buildPythonPackage rec {
  name = "zxcvbn-python-${version}";

  src = fetchPyPi {
    package = "zxcvbn-python";
    inherit version;
    sha256 = "ef982a382518d217d353a42093aa8bb8608a50bc2df559c08885bba166782cd0";
  };

  meta = with lib; {
    description = "Implementation of Dropbox's realistic password strength estimator";
    homepage = https://github.com/dwolfhub/zxcvbn-python;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
