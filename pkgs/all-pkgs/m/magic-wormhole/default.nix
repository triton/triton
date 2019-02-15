{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, attrs
, automat
, hkdf
, pynacl
, six
, spake2
, twisted
}:

let
  version = "0.11.2";
in
buildPythonPackage {
  name = "magic-wormhole-${version}";

  src = fetchPyPi {
    package = "magic-wormhole";
    inherit version;
    sha256 = "ae79667bdbb39fba7d315e36718db383651b45421813366cfaceb069e222d905";
  };

  propagatedBuildInputs = [
    attrs
    automat
    hkdf
    pynacl
    six
    spake2
    twisted
  ];

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
