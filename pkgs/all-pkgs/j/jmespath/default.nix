{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "0.9.4";
in
buildPythonPackage rec {
  name = "jmespath-${version}";

  src = fetchPyPi {
    package = "jmespath";
    inherit version;
    sha256 = "bde2aef6f44302dfb30320115b17d030798de8c4110e28d5cf6cf91a7a31074c";
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
