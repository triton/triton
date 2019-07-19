{ stdenv
, buildPythonPackage
, fetchPyPi
, isPy2
, lib
, setuptools-scm

, attrs
, functools32
, idna
, pyrsistent
, six
}:

let
  inherit (lib)
    optionals;

  version = "3.0.1";
in
buildPythonPackage rec {
  name = "jsonschema-${version}";

  src = fetchPyPi {
    package = "jsonschema";
    inherit version;
    sha256 = "0c0a81564f181de3212efa2d17de1910f8732fa1b71c42266d983cd74304e20d";
  };

  nativeBuildInputs = [
    setuptools-scm
  ];

  propagatedBuildInputs = [
    attrs
    idna
    pyrsistent
    six
  ] ++ optionals isPy2 [
    functools32
  ];

  meta = with lib; {
    decription = "An(other) implementation of JSON Schema for Python";
    homepage = https://github.com/Julian/jsonschema;
    license = licenses.mit;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
