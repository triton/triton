{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, requests
}:

let
  version = "2.5.0";
in
buildPythonPackage rec {
  name = "apache-libcloud-${version}";

  src = fetchPyPi {
    package = "apache-libcloud";
    inherit version;
    sha256 = "8f133038710257d39f9092ccaea694e31f7f4fe02c11d7fcc2674bc60a9448b6";
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
