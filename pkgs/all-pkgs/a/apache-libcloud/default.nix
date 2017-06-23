{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, requests
}:

let
  version = "2.0.0";
in
buildPythonPackage rec {
  name = "apache-libcloud-${version}";

  src = fetchPyPi {
    package = "apache-libcloud";
    inherit version;
    sha256 = "c72add0e74ca975bc51d9ad9cf3861a25825a76df56132c569b4b3c904f8e1a8";
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
