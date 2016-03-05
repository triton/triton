{ stdenv, fetchurl, cmake
, alsaSupport ? true, alsa-lib ? null
, pulseSupport ? true, pulseaudio_lib ? null
}:

with stdenv.lib;

assert alsaSupport -> alsa-lib != null;
assert pulseSupport -> pulseaudio_lib != null;

stdenv.mkDerivation rec {
  version = "1.16.0";
  name = "openal-soft-${version}";

  src = fetchurl {
    url = "http://kcat.strangesoft.net/openal-releases/${name}.tar.bz2";
    sha256 = "0pqdykdclycfnk66v166srjrry936y39d1dz9wl92qz27wqwsg9g";
  };

  buildInputs = [ cmake ]
    ++ optional alsaSupport alsa-lib
    ++ optional pulseSupport pulseaudio_lib;

  NIX_LDFLAGS = []
    ++ optional alsaSupport "-lasound"
    ++ optional pulseSupport "-lpulse";

  meta = {
    description = "OpenAL alternative";
    homepage = http://kcat.strangesoft.net/openal.html;
    license = licenses.lgpl2;
    maintainers = with maintainers; [ftrvxmtrx];
  };
}
