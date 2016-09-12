{ stdenv
, buildPythonPackage
, fetchPyPi

, docutils
, jmespath
, python-dateutil
}:

let
  version = "1.4.53";
in
buildPythonPackage rec {
  name = "botocore-${version}";

  src = fetchPyPi {
    package = "botocore";
    inherit version;
    sha256 = "7d6c96999e57145fb0b0c9534c3c7bfa9dfd30a58a4d9ccaa89f734211d987ad";
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
