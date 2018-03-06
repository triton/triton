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

let
  version = "1.2.2";
in
stdenv.mkDerivation rec {
  name = "libao-${version}";

  src = fetchFromGitHub {
    version = 3;
    owner = "xiph";
    repo = "libao";
    rev = "${version}";
    sha256 = "fa6ebe7d8c84db0ffbd375bfd856ec20e12461b29902f987fdd4910caad3e19a";
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
