{ stdenv
, fetchurl
, lib
, yasm

, enable10bit ? false
}:

let
  version = "20170620";
in
stdenv.mkDerivation rec {
  name = "x264-${version}";

  src = fetchurl {
    url = "mirror://videolan/x264/snapshots/"
      + "x264-snapshot-${version}-2245-stable.tar.bz2";
    sha256 = "17ceb937ff1347983d96c13a1b086674bd57b71f52879c3c1bf3355ce79482d1";
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
    "--disable-win32thread"
    "--disable-interlaced"
    "--bit-depth=${
      if enable10bit then
        "10"
      else
        "8"
    }"
    "--chroma-format=all"
    "--enable-pic"
    "--disable-avs"
    "--disable-swscale"
    "--disable-lavf"
    "--disable-ffms"
    "--disable-gpac"
    "--disable-lsmash"
  ];

  meta = with lib; {
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
