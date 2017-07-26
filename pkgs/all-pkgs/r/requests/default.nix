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
  version = "2.18.2";
in
buildPythonPackage {
  name = "requests-${version}";

  src = fetchPyPi {
    package = "requests";
    inherit version;
    sha256 = "5b26fcc5e72757a867e4d562333f841eddcef93548908a1bb1a9207260618da9";
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
