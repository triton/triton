{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, docutils
, jmespath
, python-dateutil
}:

let
  version = "1.10.4";
in
buildPythonPackage rec {
  name = "botocore-${version}";

  src = fetchPyPi {
    package = "botocore";
    inherit version;
    sha256 = "5602738392ecde5c02a06a3b02de07171f440a44cdfef0aadff4b59567359607";
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
