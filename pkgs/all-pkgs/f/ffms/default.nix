{ stdenv
, autoreconfHook
, fetchzip
, lib

, ffmpeg
, zlib
}:

let
  version = "2.23";
in
stdenv.mkDerivation rec {
  name = "ffms-${version}";

  src = fetchzip {
    version = 2;
    url = "https://github.com/FFMS/ffms2/archive/${version}.tar.gz";
    sha256 = "8a40f22a28e15c974906a222b44b6df29d9c50d34f41ded1ab1ad6edd6711a8d";
  };

  nativeBuildInputs = [
    autoreconfHook
  ];

  buildInputs = [
    ffmpeg
    zlib
  ];

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
