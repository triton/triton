{ stdenv
, fetchurl

, ffmpeg
, sox
}:

stdenv.mkDerivation rec {
  name = "bs1770gain-${version}";
  version = "0.4.8";

  src = fetchurl {
    url = "mirror://sourceforge/bs1770gain/${name}.tar.gz";
    sha256 = "0lyrlxfs29fxy1ldhgni8bhwr3f94kykykp2p5hhzr0lzz1n8h4l";
  };

  buildInputs = [
    ffmpeg
    sox
  ];

  postPatch =
    /* Compatibility with FFmpeg 3.0+, av_free_packet is deprecated.
       Use av_packet_unref in its place. */ ''
      sed -i libffsox-2/ffsox_source.c \
        -e 's,av_free_packet,av_packet_unref,'
    '';

  meta = with stdenv.lib; {
    description = "A audio/video loudness scanner implementing ITU-R BS.1770";
    homepage = "http://bs1770gain.sourceforge.net/";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      x86_64-linux;
  };
}
