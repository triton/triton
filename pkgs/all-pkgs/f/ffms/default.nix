{ stdenv
, autoreconfHook
, fetchzip

, ffmpeg
, zlib
}:

let
  version = "2.22";
in
stdenv.mkDerivation rec {
  name = "ffms-${version}";

  src = fetchzip {
    version = 2;
    url = "https://github.com/FFMS/ffms2/archive/${version}.tar.gz";
    sha256 = "42d9eeba82bd4741822553d8448399d6e5c32d21d26c22ff620bfb67830c24b4";
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

  meta = with stdenv.lib; {
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
