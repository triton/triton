{ stdenv
, fetchFromGitHub
}:

let
  version = "1.8.3";
in
stdenv.mkDerivation rec {
  name = "lz4-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "lz4";
    repo = "lz4";
    rev = "v${version}";
    sha256 = "1cd1213d473e8550a109faf6762cc3493ea2ec4cd4e34edaf9c85ac1479da17c";
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
