{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, docutils
, jmespath
, python-dateutil
}:

let
  version = "1.5.10";
in
buildPythonPackage rec {
  name = "botocore-${version}";

  src = fetchPyPi {
    package = "botocore";
    inherit version;
    sha256 = "9688a2984c2783257a6064c83b667f31347cbaf502d050ed249031f720c71bc3";
  };

  propagatedBuildInputs = [
    docutils
    jmespath
    python-dateutil
  ];

  meta = with lib; {
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
