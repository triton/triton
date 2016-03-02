{ stdenv
, fetchurl

, alsa-lib
, jack2_lib
, libogg
, pulseaudio_lib
}:

stdenv.mkDerivation rec {
  name = "alsa-plugins-1.1.0";

  src = fetchurl {
    urls = [
      "ftp://ftp.alsa-project.org/pub/plugins/${name}.tar.bz2"
      "http://alsa.cybermirror.org/plugins/${name}.tar.bz2"
    ];
    sha256 = "1vn9n996d5i1addb9wrr958ycps59bn09bi5zvsrkvrvjllw70rv";
  };

  # ToDo: a52, etc.?
  buildInputs = [
    alsa-lib
    jack2_lib
    libogg
    pulseaudio_lib
  ];

  meta = with stdenv.lib; {
    description = "Various plugins for ALSA";
    homepage = http://alsa-project.org/;
    license = licenses.lgpl21;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
