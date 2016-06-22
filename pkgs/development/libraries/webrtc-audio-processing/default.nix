{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "webrtc-audio-processing-0.3";

  src = fetchurl {
    url = "https://freedesktop.org/software/pulseaudio/webrtc-audio-processing/${name}.tar.xz";
    sha256 = "756e291d4f557d88cd50c4fe3b8454ec238362d22cedb3e6173240d90f0a80fa";
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
