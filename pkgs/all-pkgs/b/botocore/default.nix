{ stdenv
, buildPythonPackage
, fetchPyPi

, docutils
, jmespath
, python-dateutil
}:

let
  version = "1.4.78";
in
buildPythonPackage rec {
  name = "botocore-${version}";

  src = fetchPyPi {
    package = "botocore";
    inherit version;
    sha256 = "5053ff212b429c74b18dd7a8aa27eec057e16c17a841c67d4c6a2b4b620abd1e";
  };

  propagatedBuildInputs = [
    docutils
    jmespath
    python-dateutil
  ];

  meta = with stdenv.lib; {
    description = "The low-level, core functionality of boto 3";
    homepage = https://github.com/boto/botocore;
    license = licenses.asl20;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
