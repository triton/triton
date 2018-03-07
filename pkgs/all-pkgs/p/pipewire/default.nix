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
  version = "0.1.9";
in
stdenv.mkDerivation rec {
  name = "pipewire-${version}";

  src = fetchFromGitHub {
    version = 5;
    owner = "PipeWire";
    repo = "pipewire";
    rev = "${version}";
    sha256 = "db970f2b8e5bf72fcb7691e01646300b5a613f20f27697c95ca39340687a8b11";
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

  postPatch = /* Fix hardcoded systemd unit directory */ ''
    sed -i src/daemon/systemd/user/meson.build \
      -e "s,systemd_user_services_dir\s=.*,systemd_user_services_dir = '$out/lib/systemd/user/',"
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
