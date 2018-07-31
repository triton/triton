{ stdenv
, fetchFromGitHub
}:

let
  version = "159";
in
stdenv.mkDerivation {
  name = "mcelog-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "andikleen";
    repo = "mcelog";
    rev = "v${version}";
    sha256 = "953e0e461e08ae1d0d43d80f7c1a22df7690f4d8b282c76001cbb1ac22ef175d";
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
