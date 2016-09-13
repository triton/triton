{ stdenv
, buildPythonPackage
, fetchPyPi
}:

buildPythonPackage rec {
  name = "attrs-${version}";
  version = "16.1.0";

  src = fetchPyPi {
    package = "attrs";
    inherit version;
    sha256 = "50f1277dbc9880098afc13cda5eb1bb2efbc1d083559a932f528baee3fba1282";
  };

  meta = with stdenv.lib; {
    description = "Attributes without boilerplate";
    homepage = https://github.com/hynek/attrs;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
