{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, requests
}:

let
  version = "0.8.0";
in
buildPythonPackage rec {
  name = "requests-toolbelt-${version}";

  src = fetchPyPi {
    package = "requests-toolbelt";
    inherit version;
    sha256 = "f6a531936c6fa4c6cfce1b9c10d5c4f498d16528d2a54a22ca00011205a187b5";
  };

  propagatedBuildInputs = [
    requests
  ];

  meta = with lib; {
    description = "Useful classes and functions to be used with requests";
    homepage = https://github.com/sigmavirus24/requests-toolbelt;
    license = licenses.asl20;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
