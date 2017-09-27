{ stdenv
, cmake
, fetchFromGitHub
, ninja

, alsa-lib, glib, jack2_lib, libsndfile, pkgconfig
, pulseaudio_lib }:

let
  version = "1.1.7";
in
stdenv.mkDerivation  rec {
  name = "fluidsynth-${version}";

  src = fetchFromGitHub {
    version = 3;
    owner = "FluidSynth";
    repo = "fluidsynth";
    rev = "v${version}";
    sha256 = "10301f5f845db5e7b1bd3da4f0a02fc84face2293f8974def45c7d3388be6233";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [ glib libsndfile pkgconfig alsa-lib pulseaudio_lib jack2_lib ];

  meta = with stdenv.lib; {
    description = "Real-time software synthesizer based on the SoundFont 2 specifications";
    homepage    = http://www.fluidsynth.org;
    license     = licenses.lgpl2;
    maintainers = with maintainers; [ goibhniu lovek323 ];
    platforms   = platforms.all;
  };
}
