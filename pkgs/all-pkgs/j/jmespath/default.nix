{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "0.9.3";
in
buildPythonPackage rec {
  name = "jmespath-${version}";

  src = fetchPyPi {
    package = "jmespath";
    inherit version;
    sha256 = "6a81d4c9aa62caf061cb517b4d9ad1dd300374cd4706997aff9cd6aedd61fc64";
  };

  meta = with lib; {
    description = "JSON Matching Expressions";
    homepage = https://github.com/jmespath/jmespath.py;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
