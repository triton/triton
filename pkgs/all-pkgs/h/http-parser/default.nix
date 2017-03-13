{ stdenv
, fetchFromGitHub
}:

let
  version = "2.7.1";
in
stdenv.mkDerivation {
  name = "http-parser-${version}";

  src = fetchFromGitHub {
    version = 2;
    owner = "nodejs";
    repo = "http-parser";
    rev = "v${version}";
    sha256 = "c59677ccb370d91732ddc2510f372360aa97ff36a974643ec0cb1d3384207d43";
  };

  postPatch = ''
    sed -i 's, -Werror,,g' Makefile
  '';

  preBuild = ''
    makeFlagsArray+=(
      "PREFIX=$out"
    )
  '';

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
