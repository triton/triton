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
  version = "3.0.3";

  src = fetchPyPi {
    package = "pytest";
    inherit version;
    sha256 = "f213500a356800a483e8a146ff971ae14a8df3f2c0ae4145181aad96996abee7";
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
