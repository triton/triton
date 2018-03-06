{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, requests
}:

let
  version = "2.3.0";
in
buildPythonPackage rec {
  name = "apache-libcloud-${version}";

  src = fetchPyPi {
    package = "apache-libcloud";
    inherit version;
    sha256 = "0e2eee3802163bd0605975ed1e284cafc23203919bfa80c0cc5d3cd2543aaf97";
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
