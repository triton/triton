{ stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  name = "lz4-${version}";
  version = "131";

  src = fetchFromGitHub {
    version = 1;
    owner = "Cyan4973";
    repo = "lz4";
    rev = "r${version}";
    sha256 = "2c5aba2f33913aadcfcc3942c69493cd9147be5704c94921d75ba70222a23d03";
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
