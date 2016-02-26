{ stdenv, fetchurl, flac, libogg, libvorbis, pkgconfig }:

stdenv.mkDerivation rec {
  name = "libsndfile-1.0.26";

  src = fetchurl {
    url = "http://www.mega-nerd.com/libsndfile/files/${name}.tar.gz";
    sha256 = "14jhla289cj45946h0hq2an0a9g4wkwb3v4571bla6ixfvn20rfd";
  };

  buildInputs = [ pkgconfig flac libogg libvorbis ] ;

  meta = with stdenv.lib; {
    description = "A C library for reading and writing files containing sampled sound";
    homepage    = http://www.mega-nerd.com/libsndfile/;
    license     = licenses.lgpl2Plus;
    maintainers = with maintainers; [ lovek323 ];
    platforms   = platforms.all;
  };
}
