{ stdenv
, fetchFromGitHub
, fetchpatch
, lib
, meson
, ninja

, alsa-lib
, dbus
, ffmpeg
, glib
, gst-plugins-base
, gstreamer
, jack2_lib
, libva
, libx11
, sdl
, systemd-dummy
, systemd_lib
, v4l_lib
}:

let
  version = "0.2.5";
in
stdenv.mkDerivation rec {
  name = "pipewire-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "PipeWire";
    repo = "pipewire";
    rev = "${version}";
    sha256 = "62f9ac1ef71b05885f3b4d25df96be5f2281e0e40438f8ea59d84462e190c463";
  };

  nativeBuildInputs = [
    meson
    ninja
  ];

  buildInputs = [
    alsa-lib
    dbus
    ffmpeg
    glib
    gst-plugins-base
    gstreamer
    jack2_lib
    libva
    libx11
    sdl
    systemd-dummy
    systemd_lib
    v4l_lib
  ];

  mesonFlags = [
    "-Dgstreamer=enabled"
  ];

  meta = with lib; {
    description = "Multimedia processing graphs";
    homepage = http://pipewire.org/;
    license = licenses.lgpl21;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
