{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "1.10.0";
in
buildPythonPackage rec {
  name = "six-${version}";

  src = fetchPyPi {
    package = "six";
    inherit version;
    sha256 = "105f8d68616f8248e24bf0e9372ef04d3cc10104f1980f54d57b2ce73a5ad56a";
  };

  meta = with lib; {
    description = "Python 2 and 3 compatibility utilities";
    homepage = https://bitbucket.org/gutworth/six;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
