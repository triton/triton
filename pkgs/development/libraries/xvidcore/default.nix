{ stdenv, fetchurl, yasm }:

with stdenv.lib;
stdenv.mkDerivation rec {
  name = "xvidcore-${version}";
  version = "1.3.4";

  src = fetchurl {
    url = "http://downloads.xvid.org/downloads/${name}.tar.bz2";
    sha256 = "1xwbmp9wqshc0ckm970zdpi0yvgqxlqg0s8bkz98mnr8p2067bsz";
  };

  preConfigure = ''
    # Configure script is not in the root of the source directory
    cd build/generic
  '';

  nativeBuildInputs = [ yasm ];

  postInstall = ''
    rm $out/lib/*.a
  '';

  meta = {
    description = "MPEG-4 video codec for PC";
    homepage    = https://www.xvid.com/;
    license     = licenses.gpl2;
    maintainers = with maintainers; [ codyopel lovek323 ];
    platforms   = platforms.all;
  };
}

