{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "1.0.1";
in
buildPythonPackage {
  name = "sphinxcontrib-websupport-${version}";

  src = fetchPyPi {
    package = "sphinxcontrib-websupport";
    inherit version;
    sha256 = "7a85961326aa3a400cd4ad3c816d70ed6f7c740acd7ce5d78cd0a67825072eb9";
  };

  propagatedBuildInputs = [
  ];

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
