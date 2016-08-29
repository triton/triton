{ stdenv
, buildPythonPackage
, fetchPyPi
, isPyPy

, libiodbc
}:

let
  version = "3.0.10";
in
buildPythonPackage rec {
  name = "pyodbc-${version}";

  src = fetchPyPi {
    package = "pyodbc";
    inherit version;
    sha256 = "a66d4f347f036df49a00addf38ca6769ad52f61acdb931c95bc3a9245d8f2b58";
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
