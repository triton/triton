{ stdenv
, fetchurl
, yasm

, enable10bit ? false
, chroma ? "all"
}:

with {
  inherit (stdenv.lib)
    enFlag
    otFlag;
};

assert (
  chroma == "420" ||
  chroma == "422" ||
  chroma == "444" ||
  chroma == "all"
);

stdenv.mkDerivation rec {
  name = "x264-${version}";
  version = "20160301";

  src = fetchurl {
    url = "http://ftp.videolan.org/pub/videolan/x264/snapshots/" +
          "x264-snapshot-${version}-2245-stable.tar.bz2";
    sha256 = "1h023a2id71mk15rcgk838lwqc6alk2df0nyflg7ycb97f85ckys";
  };

  nativeBuildInputs = [
    yasm
  ];

  postPatch = ''
    patchShebangs ./configure
    patchShebangs ./version.sh
  '';

  configureFlags = [
    "--enable-shared"
    "--disable-interlaced"
    "--bit-depth=${
      if (enable10bit) then
        "10"
      else
        "8"
    }"
    "--chroma-format=${chroma}"
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
    homepage = http://www.videolan.org/developers/x264.html;
    license = licenses.gpl2;
    maintainers = [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
