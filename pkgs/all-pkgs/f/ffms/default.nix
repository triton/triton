{ stdenv
, autoreconfHook
, fetchFromGitHub
, lib

, ffmpeg
, zlib
}:

let
  version = "2017-12-16";
in
stdenv.mkDerivation rec {
  name = "ffms-${version}";

  src = fetchFromGitHub {
    version = 5;
    owner = "ffms";
    repo = "ffms2";
    rev = "c5bec2e3d5236a48d6e681b369766a0460baa786";
    sha256 = "762d9a16e0c9d06bbbc7a5ed774bec84f07d92316c50a65198fc3cd3578166b9";
  };

  nativeBuildInputs = [
    autoreconfHook
  ];

  buildInputs = [
    ffmpeg
    zlib
  ];

  preAutoreconf = ''
    mkdir -pv src/config
  '';

  configureFlags = [
    "--disable-debug"
    "--with-zlib=${zlib}"
  ];

  meta = with lib; {
    description = "FFmpeg based library and Avisynth plugin";
    homepage = https://github.com/FFMS/ffms2;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
