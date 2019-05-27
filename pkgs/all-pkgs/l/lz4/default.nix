{ stdenv
, fetchFromGitHub
}:

let
  version = "1.9.1";
in
stdenv.mkDerivation rec {
  name = "lz4-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "lz4";
    repo = "lz4";
    rev = "v${version}";
    sha256 = "b76df8241d12e3e65a471609c440e75768b7712e07f3ccdf3729f09310415bcb";
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
