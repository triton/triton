{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, six
}:

let
  version = "1.9.0";
in
buildPythonPackage rec {
  name = "pylast-${version}";

  src = fetchPyPi {
    package = "pylast";
    inherit version;
    sha256 = "ae1c4105cbe704d9ac10ba57ac4c26bc576cc33978f1b578101b20c6a2360ca4";
  };

  propagatedBuildInputs = [
    six
  ];

  meta = with lib; {
    description = "A Python interface to Last.fm and Libre.fm";
    homepage = https://github.com/pylast/pylast;
    license = licenses.asl20;
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      x86_64-linux;
  };
}
