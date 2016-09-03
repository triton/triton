{ stdenv
, buildPythonPackage
, fetchFromGitHub

, frozendict
, simplejson
}:

let
  version = "1.0.0";
in
buildPythonPackage {
  name = "canonicaljson-${version}";

  src = fetchFromGitHub {
    version = 1;
    owner = "matrix-org";
    repo = "python-canonicaljson";
    rev = "v${version}";
    sha256 = "e4aa26819eca15804c59db079625c41845a9e150d7558525c3f2d45fc5f371ee";
  };

  propagatedBuildInputs = [
    frozendict
    simplejson
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
