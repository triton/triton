{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, docutils
, jmespath
, python-dateutil
}:

let
  version = "1.5.72";
in
buildPythonPackage rec {
  name = "botocore-${version}";

  src = fetchPyPi {
    package = "botocore";
    inherit version;
    sha256 = "b988b0443fecaefc6fc6ab2bf1c36dda2790a99e82a0ddba1c982652590f3356";
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
