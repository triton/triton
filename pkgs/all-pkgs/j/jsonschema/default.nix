{ stdenv
, buildPythonPackage
, fetchPyPi
, isPy2
, lib

, functools32
, vcversioner
}:

let
  inherit (lib)
    optionals;

  version = "2.6.0";
in
buildPythonPackage rec {
  name = "jsonschema-${version}";

  src = fetchPyPi {
    package = "jsonschema";
    inherit version;
    sha256 = "6ff5f3180870836cae40f06fa10419f557208175f13ad7bc26caa77beb1f6e02";
  };

  buildInputs = [
    vcversioner
  ];

  propagatedBuildInputs = optionals isPy2 [
    functools32
  ];

  meta = with lib; {
    license = licenses.mit;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
