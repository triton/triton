{ stdenv
, fetchFromGitHub
}:

let
  version = "153";
in
stdenv.mkDerivation {
  name = "mcelog-${version}";

  src = fetchFromGitHub {
    version = 3;
    owner = "andikleen";
    repo = "mcelog";
    rev = "v${version}";
    sha256 = "e1b501de5793c2b07daa81cc6136bfb007c4c2484d92652f4d2d775b6187e387";
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
