{ stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  name = "lz4-${version}";
  version = "131";

  src = fetchFromGitHub {
    sha256 = "1bhvcq8fxxsqnpg5qa6k3nsyhq0nl0iarh08sqzclww27hlpyay2";
    rev = "r${version}";
    repo = "lz4";
    owner = "Cyan4973";
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
