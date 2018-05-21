{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, docutils
, jmespath
, python-dateutil
}:

let
  version = "1.10.24";
in
buildPythonPackage rec {
  name = "botocore-${version}";

  src = fetchPyPi {
    package = "botocore";
    inherit version;
    sha256 = "b7a23361bcd6ce2d9cf56a3e5bc7c6b2e3233f3d902d41cb2dfb37472ea41986";
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
