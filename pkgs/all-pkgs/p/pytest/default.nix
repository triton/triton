{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, isPy3k
, py
}:

let
  inherit (lib)
    optionalString;
in
buildPythonPackage rec {
  name = "pytest-${version}";
  version = "3.0.4";

  src = fetchPyPi {
    package = "pytest";
    inherit version;
    sha256 = "879fee2c1fdbaacd1bf2c0047677c6dd4aee05b9c1e64330b34d130a584fa40d";
  };

  propagatedBuildInputs = [
    py
  ];

  meta = with lib; {
    description = "Simple powerful testing framework for Python";
    homepage = https://pytest.org/;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
