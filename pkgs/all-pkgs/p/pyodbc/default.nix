{ stdenv
, buildPythonPackage
, fetchPyPi
, isPyPy
, lib

, libiodbc
}:

let
  version = "4.0.21";
in
buildPythonPackage rec {
  name = "pyodbc-${version}";

  src = fetchPyPi {
    package = "pyodbc";
    inherit version;
    sha256 = "9655f84ca9e5cb2dfffff705601017420c840d55271ba62dd44f05383eff0329";
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
