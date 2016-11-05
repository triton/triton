{ stdenv
, fetchurl
, lib

, alsa-lib
, jack2_lib
}:

let
  inherit (lib)
    boolWt;

  version = "190600_20161030";
in
stdenv.mkDerivation rec {
  name = "portaudio-${version}";

  src = fetchurl {
    url = "http://www.portaudio.com/archives/pa_stable_v${version}.tgz";
    sha256 = "f5a21d7dcd6ee84397446fa1fa1a0675bb2e8a4a6dceb4305a8404698d8d1513";
  };

  buildInputs = [
    alsa-lib
    jack2_lib
  ];

  configureFlags = [
    "--disable-debug-output"
    "--enable-cxx"
    "--disable-mac-debug"  # macos
    "--disable-mac-universal"  # macos
    "--${boolWt (alsa-lib != null)}-alsa"
    "--${boolWt (jack2_lib != null)}-jack"
    "--without-oss"
    "--without-asihpi"
    "--without-winapi"  # windows
    "--without-asiodir" # asio (windows only)
    "--without-dxdir"  # windows
  ];

  parallelBuild = false;

  meta = with lib; {
    description = "Portable cross-platform Audio API";
    homepage = http://www.portaudio.com/;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
