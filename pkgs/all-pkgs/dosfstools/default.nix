{ stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  name = "dosfstools-${version}";
  version = "3.0.28";

  src = fetchFromGitHub {
    owner = "dosfstools";
    repo = "dosfstools";
    rev = "v${version}";
    sha256 = "37c15455fd363278d85ac9f97b41c56eafc6e21170fe4aec683f1ef108758dc0";
  };

  preBuild = ''
    makeFlagsArray+=("PREFIX=$out")
  '';

  meta = with stdenv.lib; {
    description = "Utilities for creating and checking FAT and VFAT file systems";
    repositories.git = git://daniel-baumann.ch/git/software/dosfstools.git;
    homepage = http://www.daniel-baumann.ch/software/dosfstools/;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
