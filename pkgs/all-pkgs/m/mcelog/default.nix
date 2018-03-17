{ stdenv
, fetchFromGitHub
}:

let
  version = "157";
in
stdenv.mkDerivation {
  name = "mcelog-${version}";

  src = fetchFromGitHub {
    version = 5;
    owner = "andikleen";
    repo = "mcelog";
    rev = "v${version}";
    sha256 = "4ce55ecc4077777870c42fd3ace43df9ca060d240edcc5b22c8f33463bc4c570";
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
