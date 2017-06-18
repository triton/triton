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
  version = "2.18.1";
in
buildPythonPackage {
  name = "requests-${version}";

  src = fetchPyPi {
    package = "requests";
    inherit version;
    sha256 = "c6f3bdf4a4323ac7b45d01e04a6f6c20e32a052cd04de81e05103abc049ad9b9";
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
