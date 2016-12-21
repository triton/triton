{ stdenv
, buildPythonPackage
, fetchPyPi

, six
}:

let
  version = "2.6.0";
in
buildPythonPackage {
  name = "python-dateutil-${version}";

  src = fetchPyPi {
    package = "python-dateutil";
    inherit version;
    sha256 = "62a2f8df3d66f878373fd0072eacf4ee52194ba302e00082828e0d263b0418d2";
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
