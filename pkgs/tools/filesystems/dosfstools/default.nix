{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  name = "dosfstools-${version}";
  version = "3.0.28";

  src = fetchFromGitHub {
    owner = "dosfstools";
    repo = "dosfstools";
    rev = "v${version}";
    sha256 = "17bbe2ae19c96c1adbc44e832de5539128ca2f8e11b0c2fbb9cdf92242623681";
  };

  makeFlags = "PREFIX=$(out)";

  meta = {
    description = "Utilities for creating and checking FAT and VFAT file systems";
    repositories.git = git://daniel-baumann.ch/git/software/dosfstools.git;
    homepage = http://www.daniel-baumann.ch/software/dosfstools/;
    platforms = stdenv.lib.platforms.linux;
  };
}
