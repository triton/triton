{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "18.1.0";
in
buildPythonPackage rec {
  name = "attrs-${version}";

  src = fetchPyPi {
    package = "attrs";
    inherit version;
    sha256 = "e0d0eb91441a3b53dab4d9b743eafc1ac44476296a2053b6ca3af0b139faf87b";
  };

  meta = with lib; {
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
