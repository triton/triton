{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, requests
}:

let
  version = "2.4.0";
in
buildPythonPackage rec {
  name = "apache-libcloud-${version}";

  src = fetchPyPi {
    package = "apache-libcloud";
    inherit version;
    sha256 = "125c410996b84464b426922f1398a317869f27173a6461e32f3b1dfe671d5235";
  };

  propagatedBuildInputs = [
    requests
  ];

  meta = with lib; {
    description = "Python library for interacting with cloud service providers";
    homepage = https://libcloud.apache.org;
    license = licenses.asl20;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
