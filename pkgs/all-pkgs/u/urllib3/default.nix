{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "1.25.3";
in
buildPythonPackage {
  name = "urllib3-${version}";

  src = fetchPyPi {
    package = "urllib3";
    inherit version;
    sha256 = "dbe59173209418ae49d485b87d1681aefa36252ee85884c31346debd19463232";
  };

  meta = with lib; {
    description = "HTTP client for Python";
    homepage = https://github.com/urllib3/urllib3;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
