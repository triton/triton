{ stdenv, fetchurl, alsa-lib, glib, jack2_lib, libsndfile, pkgconfig
, pulseaudio_lib }:

stdenv.mkDerivation  rec {
  name = "fluidsynth-${version}";
  version = "1.1.6";

  src = fetchurl {
    url = "mirror://sourceforge/fluidsynth/${name}.tar.bz2";
    sha256 = "00gn93bx4cz9bfwf3a8xyj2by7w23nca4zxf09ll53kzpzglg2yj";
  };

  buildInputs = [ glib libsndfile pkgconfig ]
    ++ stdenv.lib.optionals true [ alsa-lib pulseaudio_lib jack2_lib ];

  meta = with stdenv.lib; {
    description = "Real-time software synthesizer based on the SoundFont 2 specifications";
    homepage    = http://www.fluidsynth.org;
    license     = licenses.lgpl2;
    maintainers = with maintainers; [ goibhniu lovek323 ];
    platforms   = platforms.all;
  };
}
