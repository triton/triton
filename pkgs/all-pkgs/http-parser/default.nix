{ stdenv
, fetchFromGitHub
}:

let
  version = "2.7.0";
in
stdenv.mkDerivation {
  name = "http-parser-${version}";

  src = fetchFromGitHub {
    owner = "nodejs";
    repo = "http-parser";
    rev = "v${version}";
    sha256 = "f780a8e4698be06c3b15c5751703aa5d0dd2437db956685c57cfc89ed6d6cb36";
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
