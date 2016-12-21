{ stdenv
, buildPythonPackage
, fetchPyPi
}:

let
  version = "2.12.4";
in
buildPythonPackage {
  name = "requests-${version}";

  src = fetchPyPi {
    package = "requests";
    inherit version;
    sha256 = "ed98431a0631e309bb4b63c81d561c1654822cb103de1ac7b47e45c26be7ae34";
  };

  meta = with stdenv.lib; {
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
