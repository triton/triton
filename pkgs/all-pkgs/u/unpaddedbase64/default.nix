{ stdenv
, buildPythonPackage
, fetchFromGitHub
}:

let
  version = "1.1.0";
in
buildPythonPackage {
  name = "unpaddedbase64-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "matrix-org";
    repo = "python-unpaddedbase64";
    rev = "v${version}";
    sha256 = "15a2f090a1c5dd865c2cd11763cf2a8f55fa4762bc4c751989225f93afcff4cf";
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
