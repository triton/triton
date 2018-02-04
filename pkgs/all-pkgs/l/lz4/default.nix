{ stdenv
, fetchFromGitHub
}:

let
  version = "1.8.1.2";
in
stdenv.mkDerivation rec {
  name = "lz4-${version}";

  src = fetchFromGitHub {
    version = 5;
    owner = "lz4";
    repo = "lz4";
    rev = "v${version}";
    sha256 = "b44320c0cc8db426fb527245bf5189e9a6a9901b92d2cc8ed6e9b07a330e3b06";
  };

  preBuild = ''
    makeFlagsArray+=("PREFIX=$out")
  '';

  buildParallel = false;

  meta = with stdenv.lib; {
    description = "Extremely fast compression algorithm";
    homepage = https://code.google.com/p/lz4/;
    license = with licenses; [ bsd2 gpl2Plus ];
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
