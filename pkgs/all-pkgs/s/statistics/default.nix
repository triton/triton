{ stdenv
, buildPythonPackage
, fetchPyPi
, isPy3
, lib

, docutils
}:

let
  version = "1.0.3.5";
in
buildPythonPackage rec {
  name = "statistics-${version}";

  src = fetchPyPi {
    package = "statistics";
    inherit version;
    sha256 = "2dc379b80b07bf2ddd5488cad06b2b9531da4dd31edb04dc9ec0dc226486c138";
  };

  propagatedBuildInputs = [
    docutils
  ];

  disabled = isPy3;  # >3.4
  doCheck = false;

  meta = with lib; {
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
