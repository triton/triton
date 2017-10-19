{ stdenv
, buildPythonPackage
, fetchPyPi

, six
}:

let
  version = "2.6.1";
in
buildPythonPackage {
  name = "python-dateutil-${version}";

  src = fetchPyPi {
    package = "python-dateutil";
    inherit version;
    sha256 = "891c38b2a02f5bb1be3e4793866c8df49c7d19baabf9c1bad62547e0b4866aca";
  };

  propagatedBuildInputs = [
    six
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
