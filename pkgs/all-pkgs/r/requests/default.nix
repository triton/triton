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
  version = "2.21.0";
in
buildPythonPackage {
  name = "requests-${version}";

  src = fetchPyPi {
    package = "requests";
    inherit version;
    sha256 = "502a824f31acdacb3a35b6690b5fbf0bc41d63a24a45c4004352b0242707598e";
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
