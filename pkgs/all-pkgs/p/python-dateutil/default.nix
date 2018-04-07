{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, setuptools-scm
, six
}:

let
  version = "2.7.2";
in
buildPythonPackage {
  name = "python-dateutil-${version}";

  src = fetchPyPi {
    package = "python-dateutil";
    inherit version;
    sha256 = "9d8074be4c993fbe4947878ce593052f71dac82932a677d49194d8ce9778002e";
  };

  propagatedBuildInputs = [
    setuptools-scm
    six
  ];

  doCheck = true;

  meta = with lib; {
    description = "Extensions to the standard Python datetime module";
    homepage = https://pypi.python.org/pypi/python-dateutil;
    licenses = licenses.bsd3;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
