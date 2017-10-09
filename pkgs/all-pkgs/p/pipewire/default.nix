{ stdenv
, fetchFromGitHub
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
, systemd_full
, v4l_lib
}:

let
  version = "2017-09-29";
in
stdenv.mkDerivation rec {
  name = "pipewire-${version}";

  src = fetchFromGitHub {
    version = 3;
    owner = "PipeWire";
    repo = "pipewire";
    rev = "acfdc63f26b7b2b7a465d3cc758b9c70403834df";
    sha256 = "0ebdabaeed4b55bc05ee4630b5ac937688d835551809947e10996a8acd364a88";
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
    systemd_full  # FIXME: remove hard dependency on full
    v4l_lib
  ];

  postPatch = /* Fix hardcoded systemd unit directory */ ''
    sed -i src/daemon/systemd/user/meson.build \
      -e "s,systemd_user_services_dir\s=.*,systemd_user_services_dir = '$out/lib/systemd/user/',"
  '';

  preConfigure = ''

  '';

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

