{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, jmespath
, python-dateutil
, urllib3
}:

let
  version = "1.12.49";
in
buildPythonPackage rec {
  name = "botocore-${version}";

  src = fetchPyPi {
    package = "botocore";
    inherit version;
    sha256 = "98c8268a00e4aedebf5ea2db1ad912e352354bfc008d7eb29522c746ada74987";
  };

  propagatedBuildInputs = [
    jmespath
    python-dateutil
    urllib3
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
