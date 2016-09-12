{ stdenv
, buildPythonPackage
, fetchPyPi
}:

let
  version = "0.9.0";
in
buildPythonPackage rec {
  name = "jmespath-${version}";

  src = fetchPyPi {
    package = "jmespath";
    inherit version;
    sha256 = "08dfaa06d4397f283a01e57089f3360e3b52b5b9da91a70e1fd91e9f0cdd3d3d";
  };

  meta = with stdenv.lib; {
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
