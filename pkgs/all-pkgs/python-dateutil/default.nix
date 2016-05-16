{ stdenv
, buildPythonPackage
, fetchPyPi

, pythonPackages
}:

buildPythonPackage rec {
  name = "python-dateutil-${version}";
  version = "2.5.3";

  src = fetchPyPi {
    package = "python-dateutil";
    inherit version;
    sha256 = "1408fdb07c6a1fa9997567ce3fcee6a337b39a503d80699e0f213de4aa4b32ed";
  };

  propagatedBuildInputs = [
    pythonPackages.six
  ];

  doCheck = true;

  meta = with stdenv.lib; {
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
