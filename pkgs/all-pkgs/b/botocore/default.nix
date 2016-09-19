{ stdenv
, buildPythonPackage
, fetchPyPi

, docutils
, jmespath
, python-dateutil
}:

let
  version = "1.4.55";
in
buildPythonPackage rec {
  name = "botocore-${version}";

  src = fetchPyPi {
    package = "botocore";
    inherit version;
    sha256 = "0c0a2ffa545cb4209cac4f8caad4463d12e17c052a2a643814109782a68540b8";
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
