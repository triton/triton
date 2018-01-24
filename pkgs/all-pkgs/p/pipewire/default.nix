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
  version = "0.1.8";
in
stdenv.mkDerivation rec {
  name = "pipewire-${version}";

  src = fetchFromGitHub {
    version = 5;
    owner = "PipeWire";
    repo = "pipewire";
    rev = "${version}";
    sha256 = "00157a62685f4b04b58a802c5c61b974a50c7e47c9a1a5ac3c4af44463602485";
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

  patches = [
    (fetchpatch {
      url = "https://github.com/PipeWire/pipewire/commit/b6ee67905db2124a1105da7da6969200aa305957.patch";
      sha256 = "c8f90de1392797a14ca9c589aad1ff1ac51e499e9ea3e887c7f95c5d25193e45";
    })
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
