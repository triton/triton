{ stdenv
, fetchFromGitHub
}:

let
  version = "161";
in
stdenv.mkDerivation {
  name = "mcelog-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "andikleen";
    repo = "mcelog";
    rev = "v${version}";
    sha256 = "204990223107e940b03743f2e2a299774b3fece478f91cd3870df6c88f7fd38e";
  };

  preBuild = ''
    makeFlagsArray+=(
      "etcprefix=$out"
      "prefix=$out"
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
