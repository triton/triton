{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  name = "dosfstools-${version}";
  version = "3.0.28";

  src = fetchFromGitHub {
    owner = "dosfstools";
    repo = "dosfstools";
    rev = "v${version}";
    sha256 = "755b87230dc38100aab458aede515abfe6f094d5a8379ec50b6d29782a9f06ff";
  };

  makeFlags = "PREFIX=$(out)";

  meta = {
    description = "Utilities for creating and checking FAT and VFAT file systems";
    repositories.git = git://daniel-baumann.ch/git/software/dosfstools.git;
    homepage = http://www.daniel-baumann.ch/software/dosfstools/;
    platforms = stdenv.lib.platforms.linux;
  };
}
