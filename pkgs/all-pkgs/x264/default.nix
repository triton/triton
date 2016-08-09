{ stdenv
, fetchurl
, yasm

, enable10bit ? false
}:

let
  version = "20160808";
in
stdenv.mkDerivation rec {
  name = "x264-${version}";

  src = fetchurl {
    url = "https://ftp.videolan.org/pub/videolan/x264/snapshots/"
      + "x264-snapshot-${version}-2245-stable.tar.bz2";
    sha256 = "81348d5fadc9234d4c609897ec9465d314930f9d90eeb9fa752f0c70786af83d";
  };

  nativeBuildInputs = [
    yasm
  ];

  postPatch = ''
    patchShebangs ./configure
    patchShebangs ./version.sh
  '';

  configureFlags = [
    "--enable-cli"
    # Only a static executable is built if --enable-shared is not passed
    "--enable-shared"
    #"--enable-opencl"
    "--enable-gpl"
    "--enable-thread"
    "--disable-win32thread"
    "--disable-interlaced"
    "--bit-depth=${
      if (enable10bit) then
        "10"
      else
        "8"
    }"
    "--chroma-format=all"
    "--enable-asm"
    "--disable-debug"
    "--disable-gprof"
    "--enable-pic"
    "--disable-avs"
    "--disable-swscale"
    "--disable-lavf"
    "--disable-ffms"
    "--disable-gpac"
    "--disable-lsmash"
  ];

  meta = with stdenv.lib; {
    description = "Library for encoding h.264/AVC video streams";
    homepage = https://www.videolan.org/developers/x264.html;
    license = licenses.gpl2;
    maintainers = [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
