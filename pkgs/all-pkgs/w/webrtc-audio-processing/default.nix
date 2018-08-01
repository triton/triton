{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "webrtc-audio-processing-0.3.1";

  src = fetchurl {
    url = "https://freedesktop.org/software/pulseaudio/webrtc-audio-processing/${name}.tar.xz";
    multihash = "QmNRSFLT1tL3uo2uJuY5T8m4NVdmNsyejvHtVFMJWC93pi";
    sha256 = "a0fdd938fd85272d67e81572c5a4d9e200a0c104753cb3c209ded175ce3c5dbf";
  };

  meta = with stdenv.lib; {
    homepage = http://www.freedesktop.org/software/pulseaudio/webrtc-audio-processing;
    description = "a more Linux packaging friendly copy of the AudioProcessing module from the WebRTC project";
    license = licenses.bsd3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
