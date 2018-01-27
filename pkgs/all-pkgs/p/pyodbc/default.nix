{ stdenv
, buildPythonPackage
, fetchPyPi
, isPyPy
, lib

, libiodbc
}:

let
  version = "4.0.22";
in
buildPythonPackage rec {
  name = "pyodbc-${version}";

  src = fetchPyPi {
    package = "pyodbc";
    inherit version;
    sha256 = "e2d742b42c8b92b10018c51d673fe72d925ab90d4dbaaccd4f209e10e228ba73";
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
