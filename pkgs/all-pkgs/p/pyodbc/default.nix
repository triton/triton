{ stdenv
, buildPythonPackage
, fetchPyPi
, isPyPy
, lib

, libiodbc
}:

let
  version = "4.0.17";
in
buildPythonPackage rec {
  name = "pyodbc-${version}";

  src = fetchPyPi {
    package = "pyodbc";
    inherit version;
    sha256 = "a82892ba8d74318524efaaccaf8351d3a3b4079a07e1a758902a2b9e84529c9d";
  };

  buildInputs = [
    libiodbc
  ];

  # use pypyodbc instead
  disabled = isPyPy;

  meta = with lib; {
    description = "Python ODBC module to connect to almost any database";
    homepage = https://github.com/mkleehammer/pyodbc/;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
