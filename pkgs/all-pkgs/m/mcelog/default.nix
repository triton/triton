{ stdenv
, fetchFromGitHub
}:

let
  version = "149";
in
stdenv.mkDerivation {
  name = "mcelog-${version}";

  src = fetchFromGitHub {
    version = 2;
    owner = "andikleen";
    repo = "mcelog";
    rev = "v${version}";
    sha256 = "648a9b5e704b8caa0a5e7d343ec485391d8753d616da51732436396a5f779d0f";
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
