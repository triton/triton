{ stdenv
, autoreconfHook
, fetchFromGitHub
, lib

, alsa-lib
, libice
, libsm
, libx11
, libxau
, pulseaudio_lib
, xorgproto
}:

stdenv.mkDerivation rec {
  name = "libao-2018-12-29";

  src = fetchFromGitHub {
    version = 6;
    owner = "xiph";
    repo = "libao";
    rev = "20dc8ed9fa4605f5c25e7496ede42e8ba6468225";
    sha256 = "6a0506240ba8098206f7e4e522faf0eacbee2fa0a4dd6cf5b9da6e87e73be047";
  };

  nativeBuildInputs = [
    autoreconfHook
  ];

  buildInputs = [
    alsa-lib
    libice
    libsm
    libx11
    libxau
    pulseaudio_lib
    xorgproto
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    #"--enable-roar-default-slp"
    "--disable-wmm"  # Windows
    "--disable-esd"
    "--disable-esdtest"
    "--enable-alsa"
    "--enable-alsa-mmap"
    "--disable-broken-oss"
    "--disable-arts"
    "--disable-nas"
    "--enable-pulse"
  ];

  meta = with lib; {
    homepage = http://xiph.org/ao/;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      codyopel
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
