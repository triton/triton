{ stdenv
, autoreconfHook
, fetchFromGitHub
, lib

, ffmpeg
, zlib
}:

let
  version = "2017-11-21";
in
stdenv.mkDerivation rec {
  name = "ffms-${version}";

  src = fetchFromGitHub {
    version = 4;
    owner = "ffms";
    repo = "ffms2";
    rev = "c71cade921072bce46289635ed0780e5ce01beab";
    sha256 = "3cddcca60423fa7ba0b293e888632b541940ac63a4e14a3703acfa6f904aab77";
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
