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
    owner = "matrix-org";
    repo = "python-unpaddedbase64";
    rev = "v${version}";
    sha256 = "6cd66a07e89d4d13e7def16615fdb0ee37e03a70aba41ae88b54f965e5c199f9";
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
