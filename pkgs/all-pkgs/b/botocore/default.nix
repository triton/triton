{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, docutils
, jmespath
, python-dateutil
}:

let
  version = "1.8.0";
in
buildPythonPackage rec {
  name = "botocore-${version}";

  src = fetchPyPi {
    package = "botocore";
    inherit version;
    sha256 = "7f3e15054c0a2f71498ca5561c9edee7229678e2bc97a42dcb428e4dfde7b53f";
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
