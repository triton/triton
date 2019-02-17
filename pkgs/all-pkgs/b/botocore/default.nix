{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, jmespath
, python-dateutil
, urllib3
}:

let
  version = "1.12.96";
in
buildPythonPackage rec {
  name = "botocore-${version}";

  src = fetchPyPi {
    package = "botocore";
    inherit version;
    sha256 = "55c1594041e6716847d5a8b38181e3cc44e245edbf4598ae2b99e3040073b2cf";
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
