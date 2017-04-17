{ stdenv
, buildPythonPackage
, fetchPyPi

, pyopenssl
, service-identity
, twisted
}:

let
  version = "0.12.6";
in
buildPythonPackage {
  name = "foolscap-${version}";

  src = fetchPyPi {
    package = "foolscap";
    inherit version;
    sha256 = "3f4b21a266b8dc73a3ce2db5a5b7762bd4444b610227f565c9b516440cc6f5ae";
  };

  buildInputs = [
    pyopenssl
    service-identity
    twisted
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
