{ stdenv
, buildPythonPackage
, fetchPyPi

, pythonPackages
}:

buildPythonPackage rec {
  name = "statistics-${version}";
  version = "1.0.3.5";

  src = fetchPyPi {
    package = "statistics";
    inherit version;
    sha256 = "2dc379b80b07bf2ddd5488cad06b2b9531da4dd31edb04dc9ec0dc226486c138";
  };

  propagatedBuildInputs = [
    pythonPackages.docutils
  ];

  disabled = pythonPackages.isPy3k;
  doCheck = false;

  meta = with stdenv.lib; {
    description = "A Python 2.* port of 3.4 Statistics Module";
    homepage = https://pypi.python.org/pypi/statistics;
    license = licenses.asl20;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
