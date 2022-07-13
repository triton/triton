{ stdenv
, cmake
, fetchFromGitHub
, ninja

, alsa-lib, glib, jack2_lib, libsndfile, pkgconfig
, pulseaudio_lib }:

let
  version = "1.1.8";
in
stdenv.mkDerivation  rec {
  name = "fluidsynth-${version}";

  src = fetchFromGitHub {
    version = 3;
    owner = "FluidSynth";
    repo = "fluidsynth";
    rev = "v${version}";
    sha256 = "f7084a7d7953b15f1281d6f23a2e021f25123a8743538d6134cc8d3d28846a30";
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
    maintainers = with maintainers; [ ];
    platforms   = platforms.all;
  };
}
