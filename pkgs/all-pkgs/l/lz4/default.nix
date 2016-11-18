{ stdenv
, fetchFromGitHub
}:

let
  version = "1.7.3";
in
stdenv.mkDerivation rec {
  name = "lz4-${version}";

  src = fetchFromGitHub {
    version = 2;
    owner = "lz4";
    repo = "lz4";
    rev = "v${version}";
    sha256 = "b4ef4e45d4a0f01fdbc5ccf87a752bd88891341f15decf07314d0a7824fa5493";
  };

  preBuild = ''
    makeFlagsArray+=("PREFIX=$out")
  '';

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
