{ stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  name = "lz4-${version}";
  version = "131";

  src = fetchFromGitHub {
    owner = "Cyan4973";
    repo = "lz4";
    rev = "r${version}";
    sha256 = "0c7d1ed694fcc3fc5caf2f21d83c61936e4720df1d11ff16dfe8bf6f390a07fb";
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
      i686-linux
      ++ x86_64-linux;
  };
}
