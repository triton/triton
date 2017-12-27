{ stdenv
, fetchFromGitHub
}:

let
  version = "1.8.0";
in
stdenv.mkDerivation rec {
  name = "lz4-${version}";

  src = fetchFromGitHub {
    version = 5;
    owner = "lz4";
    repo = "lz4";
    rev = "v${version}";
    sha256 = "b5b0694504a78bb4179dd8fec27e7ba8003edf4f094c3cb5eafbb9e14ecb2d0e";
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
