{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, pyasn1
}:

let
  version = "0.0.9";
in
buildPythonPackage {
  name = "pyasn1-modules-${version}";

  src = fetchPyPi {
    package = "pyasn1-modules";
    inherit version;
    sha256 = "be0e4157e4a53551279d6c6e366b080527f5fd068616835b4abf32c14f657f5f";
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
