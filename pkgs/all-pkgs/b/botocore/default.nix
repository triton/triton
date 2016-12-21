{ stdenv
, buildPythonPackage
, fetchPyPi

, docutils
, jmespath
, python-dateutil
}:

let
  version = "1.4.88";
in
buildPythonPackage rec {
  name = "botocore-${version}";

  src = fetchPyPi {
    package = "botocore";
    inherit version;
    sha256 = "fee22eb6fa95a3d56d9d11734f0b985d613fc7975c3a6c578592585d665c5e10";
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
