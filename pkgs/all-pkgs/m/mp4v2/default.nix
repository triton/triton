{ stdenv
, fetchTritonPatch
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "mp4v2-2.0.0";

  src = fetchurl {
    url = "https://mp4v2.googlecode.com/files/${name}.tar.bz2";
    sha256 = "0f438bimimsvxjbdp4vsr8hjw2nwggmhaxgcw07g2z361fkbj683";
  };

  meta = with stdenv.lib; {
    description = "Functions for accessing ISO-IEC:14496-1:2001 MPEG-4 standard";
    homepage = http://code.google.com/p/mp4v2;
    license = licenses.mpl11;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
