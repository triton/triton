{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, setuptools-scm
, six
}:

let
  version = "2.7.5";
in
buildPythonPackage {
  name = "python-dateutil-${version}";

  src = fetchPyPi {
    package = "python-dateutil";
    inherit version;
    sha256 = "88f9287c0174266bb0d8cedd395cfba9c58e87e5ad86b2ce58859bc11be3cf02";
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
