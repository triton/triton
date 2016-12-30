{ stdenv
, buildPythonPackage
, fetchPyPi
, isPyPy

, libiodbc
}:

let
  version = "4.0.0";
in
buildPythonPackage rec {
  name = "pyodbc-${version}";

  src = fetchPyPi {
    package = "pyodbc";
    inherit version;
    sha256 = "dbd416e5afce6243e2c242a760f48db44914c049a416ebf7bd83768523476c34";
  };

  buildInputs = [
    libiodbc
  ];

  # use pypyodbc instead
  disabled = isPyPy;

  meta = with stdenv.lib; {
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
