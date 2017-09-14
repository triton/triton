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
  version = "2.18.4";
in
buildPythonPackage {
  name = "requests-${version}";

  src = fetchPyPi {
    package = "requests";
    inherit version;
    sha256 = "9c443e7324ba5b85070c4a818ade28bfabedf16ea10206da1132edaa6dda237e";
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
