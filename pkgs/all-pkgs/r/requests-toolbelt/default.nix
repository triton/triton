{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, requests
}:

let
  version = "0.7.0";
in
buildPythonPackage rec {
  name = "requests-toolbelt-${version}";

  src = fetchPyPi {
    package = "requests-toolbelt";
    inherit version;
    sha256 = "33899d4a559c3f0f5e9fbc115d337c4236febdc083755a160a4132d92fc3c91a";
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
