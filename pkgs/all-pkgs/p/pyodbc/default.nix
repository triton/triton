{ stdenv
, buildPythonPackage
, fetchurl

, isPyPy
, pkgs
}:

buildPythonPackage rec {
  name = "pyodbc-3.0.10";

  src = pkgs.fetchurl {
    url = "https://pyodbc.googlecode.com/files/${name}.zip";
    sha256 = "0ldkm8xws91j7zbvpqb413hvdz8r66bslr451q3qc0xi8cnmydfq";
  };

  buildInputs = [
    pkgs.libiodbc
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
