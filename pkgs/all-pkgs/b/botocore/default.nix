{ stdenv
, buildPythonPackage
, fetchPyPi

, docutils
, jmespath
, python-dateutil
}:

let
  version = "1.4.71";
in
buildPythonPackage rec {
  name = "botocore-${version}";

  src = fetchPyPi {
    package = "botocore";
    inherit version;
    sha256 = "c42d350fffbb1374ac6bcd983b7c84d3f4c3dd489cce9840cad47cd21863b5f4";
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
