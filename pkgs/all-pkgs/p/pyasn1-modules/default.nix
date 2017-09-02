{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, pyasn1
}:

let
  version = "0.1.1";
in
buildPythonPackage {
  name = "pyasn1-modules-${version}";

  src = fetchPyPi {
    package = "pyasn1-modules";
    inherit version;
    sha256 = "017b6a20725c79f1329e9f446d90ebbeab9d9b322bde0c26d46840b367fb915d";
  };

  buildInputs = [
    pyasn1
  ];

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
