{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, pyasn1
}:

let
  version = "0.2.4";
in
buildPythonPackage {
  name = "pyasn1-modules-${version}";

  src = fetchPyPi {
    package = "pyasn1-modules";
    inherit version;
    sha256 = "a52090e8c5841ebbf08ae455146792d9ef3e8445b21055d3a3b7ed9c712b7c7c";
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
