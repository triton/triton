{ stdenv
, buildPythonPackage
, fetchPyPi

, isPy3k
, py
}:

let
  inherit (stdenv.lib)
    optionalString;
in

buildPythonPackage rec {
  name = "pytest-${version}";
  version = "2.9.2";

  src = fetchPyPi {
    package = "pytest";
    inherit version;
    sha256 = "12c18abb9a09a5b2802dba75c7a2d7d6c8c0f1258abd8243e7688415d87ad1d8";
  };

  propagatedBuildInputs = [
    py
  ];

  meta = with stdenv.lib; {
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
