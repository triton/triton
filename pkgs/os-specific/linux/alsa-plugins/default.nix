{ stdenv
, fetchurl

, alsa-lib
, jack2_lib
, libogg
, pulseaudio_lib
}:

stdenv.mkDerivation rec {
  name = "alsa-plugins-1.1.1";

  src = fetchurl {
    urls = [
      "ftp://ftp.alsa-project.org/pub/plugins/${name}.tar.bz2"
      "http://alsa.cybermirror.org/plugins/${name}.tar.bz2"
    ];
    sha256 = "8ea4d1e082c36528a896a2581e5eb62d4dc2683238e353050d0d624e65f901f1";
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
