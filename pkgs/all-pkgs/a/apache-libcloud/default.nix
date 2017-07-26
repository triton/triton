{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, requests
}:

let
  version = "2.1.0";
in
buildPythonPackage rec {
  name = "apache-libcloud-${version}";

  src = fetchPyPi {
    package = "apache-libcloud";
    inherit version;
    sha256 = "7e812f730495e5d59d0adb06792115241f08a59566d25445613b15f008c73a05";
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
