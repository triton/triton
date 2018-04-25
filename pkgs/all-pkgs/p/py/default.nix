{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "1.5.3";
in
buildPythonPackage rec {
  name = "py-${version}";

  src = fetchPyPi {
    package = "py";
    inherit version;
    sha256 = "29c9fab495d7528e80ba1e343b958684f4ace687327e6f789a94bf3d1915f881";
  };

  doCheck = false;

  meta = with lib; {
    description = "Cross-python path, ini-parsing, io, code, log facilities";
    homepage = http://bitbucket.org/pytest-dev/py/;
    licenses = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
