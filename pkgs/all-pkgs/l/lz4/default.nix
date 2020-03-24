{ stdenv
, fetchFromGitHub
}:

let
  version = "1.9.2";
in
stdenv.mkDerivation rec {
  name = "lz4-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "lz4";
    repo = "lz4";
    rev = "v${version}";
    sha256 = "ece83b4ea00b0cde4103723fb4e2db978418261e489b40f4d078db473161cd11";
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
