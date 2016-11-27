{ stdenv
, fetchFromGitHub
}:

let
  version = "1.7.4.2";
in
stdenv.mkDerivation rec {
  name = "lz4-${version}";

  src = fetchFromGitHub {
    version = 2;
    owner = "lz4";
    repo = "lz4";
    rev = "v${version}";
    sha256 = "c50d5b0e5b9ddcbd67693c550038e5061973587a14b5dab55b4b8e1bb42fc094";
  };

  preBuild = ''
    makeFlagsArray+=("PREFIX=$out")
  '';

  parallelBuild = false;

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
