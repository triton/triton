{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, certifi
, chardet
, idna
, urllib3
}:

let
  version = "2.18.3";
in
buildPythonPackage {
  name = "requests-${version}";

  src = fetchPyPi {
    package = "requests";
    inherit version;
    sha256 = "fb68a7baef4965c12d9cd67c0f5a46e6e28be3d8c7b6910c758fbcc99880b518";
  };

  propagatedBuildInputs = [
    certifi
    chardet
    idna
    urllib3
  ];

  meta = with lib; {
    description = "HTTP library for Python";
    homepage = http://python-requests.org/;
    license = licenses.asl20;
    maintainers = with maintainers; [
      codyopel
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
