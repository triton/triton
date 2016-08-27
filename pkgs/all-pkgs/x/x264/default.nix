{ stdenv
, fetchurl
, yasm

, enable10bit ? false
}:

let
  version = "20160827";
in
stdenv.mkDerivation rec {
  name = "x264-${version}";

  src = fetchurl {
    url = "https://ftp.videolan.org/pub/videolan/x264/snapshots/"
      + "x264-snapshot-${version}-2245-stable.tar.bz2";
    sha256 = "1a985db59a64fda7dabac73b705ee7b0efac7ab34767a20c4730973b785d299d";
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
      if enable10bit then
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
