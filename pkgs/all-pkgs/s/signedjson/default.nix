{ stdenv
, buildPythonPackage
, fetchFromGitHub

, canonicaljson
, pynacl
, unpaddedbase64
}:

let
  version = "1.0.0";
in
buildPythonPackage {
  name = "signedjson-${version}";

  src = fetchFromGitHub {
    version = 3;
    owner = "matrix-org";
    repo = "python-signedjson";
    rev = "v${version}";
    sha256 = "6bf97a66408b4cffb5fcee2e350792f7f7216cba58ad85394b5f88f42dd31a88";
  };

  propagatedBuildInputs = [
    canonicaljson
    pynacl
    unpaddedbase64
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
