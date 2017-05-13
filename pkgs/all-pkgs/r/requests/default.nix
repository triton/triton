{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "2.14.2";
in
buildPythonPackage {
  name = "requests-${version}";

  src = fetchPyPi {
    package = "requests";
    inherit version;
    sha256 = "a274abba399a23e8713ffd2b5706535ae280ebe2b8069ee6a941cb089440d153";
  };

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
