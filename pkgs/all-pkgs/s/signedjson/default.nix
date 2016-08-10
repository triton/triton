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
    owner = "matrix-org";
    repo = "python-signedjson";
    rev = "v${version}";
    sha256 = "49440862475876d1e71e3d142ba75703cde7ccbffb77f20905d779a571118043";
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
