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
    version = 6;
    owner = "matrix-org";
    repo = "python-signedjson";
    rev = "v${version}";
    sha256 = "e786d2888b9f61df7eb750a3832e5edae552bc433236f8bf9a7c1949dacc51ad";
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
