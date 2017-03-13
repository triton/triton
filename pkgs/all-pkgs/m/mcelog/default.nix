{ stdenv
, fetchFromGitHub
}:

let
  version = "148";
in
stdenv.mkDerivation {
  name = "mcelog-${version}";

  src = fetchFromGitHub {
    version = 2;
    owner = "andikleen";
    repo = "mcelog";
    rev = "v${version}";
    sha256 = "d577a4f3f5edc62fbd720df1c3cb03afc44114b51bc2a98b202323838c38881c";
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
