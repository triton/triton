{ stdenv, fetchurl, cmake, ninja
, alsaSupport ? true, alsa-lib ? null
, pulseSupport ? true, pulseaudio_lib ? null
}:

with stdenv.lib;

assert alsaSupport -> alsa-lib != null;
assert pulseSupport -> pulseaudio_lib != null;

stdenv.mkDerivation rec {
  version = "1.17.2";
  name = "openal-soft-${version}";

  src = fetchurl {
    urls = [
      "mirror://gentoo/distfiles/${name}.tar.bz2"
      "http://kcat.strangesoft.net/openal-releases/${name}.tar.bz2"
    ];
    sha256 = "a341f8542f1f0b8c65241a17da13d073f18ec06658e1a1606a8ecc8bbc2b3314";
  };

  buildInputs = [ cmake ninja ]
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
