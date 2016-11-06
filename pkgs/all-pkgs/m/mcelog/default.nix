{ stdenv
, fetchFromGitHub
}:

let
  version = "144";
in
stdenv.mkDerivation {
  name = "mcelog-${version}";

  src = fetchFromGitHub {
    version = 2;
    owner = "andikleen";
    repo = "mcelog";
    rev = "v${version}";
    sha256 = "c9bae41d7e2dd93d3e43daaadcfb53f3b0852bb41012270b0c8f61a0f47d3b3c";
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
