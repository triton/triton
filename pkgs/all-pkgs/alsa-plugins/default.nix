{ stdenv
, fetchurl

, alsa-lib
, ffmpeg
, jack2_lib
, libogg
, libsamplerate
, pulseaudio_lib
, speexdsp
}:

stdenv.mkDerivation rec {
  name = "alsa-plugins-1.1.1";

  src = fetchurl {
    url = "mirror://alsa/plugins/${name}.tar.bz2";
    multihash = "QmXoLUNpmc8QLw37jPvDMYqCb15QfmtqjYp2PeA1VWXaeu";
    sha256 = "8ea4d1e082c36528a896a2581e5eb62d4dc2683238e353050d0d624e65f901f1";
  };

  buildInputs = [
    alsa-lib
    jack2_lib
    libogg
    libsamplerate
    pulseaudio_lib
    speexdsp
  ];

  meta = with stdenv.lib; {
    description = "Various plugins for ALSA";
    homepage = http://alsa-project.org/;
    license = licenses.lgpl21;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
