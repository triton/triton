{ stdenv
, fetchurl

, alsa-lib
, ffmpeg
, jack2_lib
, libsamplerate
, pulseaudio_lib
, speexdsp
}:

stdenv.mkDerivation rec {
  name = "alsa-plugins-1.1.6";

  src = fetchurl {
    url = "mirror://alsa/plugins/${name}.tar.bz2";
    multihash = "QmbHz8QeVAitVks4Nn5PcgnFgRsGNPuZEBXjHaajVUZT61";
    sha256 = "6f1d31ebe3b1fa1cc8dade60b7bed1cb2583ac998167002d350dc0a5e3e40c13";
  };

  buildInputs = [
    alsa-lib
    #ffmpeg
    jack2_lib
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
