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
  name = "alsa-plugins-1.1.5";

  src = fetchurl {
    url = "mirror://alsa/plugins/${name}.tar.bz2";
    multihash = "QmcqwpskPPY7WBKqi69PDXbfkACgWdtdHfpSuVFMCUbuuK";
    sha256 = "797da5f8f53379fbea28817bc466de16affd2c07849e84f1af8d5e22f7bb7f1c";
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
