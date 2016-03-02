{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  name = "libdvbpsi-${version}";
  version = "1.3.0";

  src = fetchurl {
    url = "http://download.videolan.org/pub/libdvbpsi/${version}/${name}.tar.bz2";
    sha256 = "1zm1n1np0nmx209m66ky4bvf06978vi2j7xxkf8jyrl0378x3zm2";
  };

  meta = {
    description = "A simple library designed for decoding and generation of MPEG TS and DVB PSI tables according to standards ISO/IEC 13818 and ITU-T H.222.0";
    homepage = http://www.videolan.org/developers/libdvbpsi.html ;
    platforms = stdenv.lib.platforms.all;
    license = stdenv.lib.licenses.lgpl21;
  };

}
