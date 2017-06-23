{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "1.4.34";
in
buildPythonPackage rec {
  name = "py-${version}";

  src = fetchPyPi {
    package = "py";
    inherit version;
    sha256 = "0f2d585d22050e90c7d293b6451c83db097df77871974d90efd5a30dc12fcde3";
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
