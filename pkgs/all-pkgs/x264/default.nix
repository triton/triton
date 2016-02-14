{ stdenv
, fetchurl
, yasm

, enable10bit ? false
, chroma ? "all"
}:

with {
  inherit (stdenv)
    isi686
    is64bit;
  inherit (stdenv.lib)
    enFlag
    otFlag;
};

assert enable10bit -> is64bit;
assert (
  chroma == "420" ||
  chroma == "422" ||
  chroma == "444" ||
  chroma == "all"
);

stdenv.mkDerivation rec {
  name = "x264-${version}";
  version = "20160119";

  src = fetchurl {
    url = "http://ftp.videolan.org/pub/videolan/x264/snapshots/" +
          "x264-snapshot-${version}-2245-stable.tar.bz2";
    sha256 = "1m7gncijx5wpsgrallmam8zl0sshx3di6svv0kj8rnp3wydn8q98";
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
    "--enable-shared"
    "--enable-opencl"
    "--enable-gpl"
    "--enable-thread"
    "--disable-win32thread"
    "--disable-interlaced"
    "--bit-depth=${
      if (enable10bit && is64bit) then
        "10"
      else
        "8"
    }"
    "--chroma-format=${chroma}"
    "--enable-asm"
    "--disable-debug"
    "--disable-gprof"
    (enFlag "pic" (!isi686) null)
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
      i686-linux
      ++ x86_64-linux;
  };
}
