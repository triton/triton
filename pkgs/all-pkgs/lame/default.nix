{ stdenv
, fetchTritonPatch
, fetchurl
, nasm

# Use libsndfile instead of lame's internal routines
, sndfileFileIOSupport ? false
  , libsndfile
}:

let
  inherit (stdenv)
    targetSystem;
  inherit (stdenv.lib)
    elem
    enFlag
    optional
    platforms
    wtFlag;
in

let
  sndfileFileIO =
    if sndfileFileIOSupport then
      "sndfile"
    else
      "lame";
in

stdenv.mkDerivation rec {
  name = "lame-${version}";
  version = "3.99.5";

  src = fetchurl {
    url = "mirror://sourceforge/lame/${name}.tar.gz";
    sha256 = "1zr3kadv35ii6liia0bpfgxpag27xcivp571ybckpbz4b10nnd14";
  };

  patches = [
    (fetchTritonPatch {
      rev = "7b4e03ea2c1aa248c38b4f55ed4892bfceaf4d32";
      file = "lame/lame-gcc-4.9.patch";
      sha256 = "9f675fa1a5ef15111bb51253b31fc88dbf9b21a5111e38ac0060b97abe42b39f";
    })
  ];

  nativeBuildInputs = [
    nasm
  ];

  buildInputs = [ ]
    ++ optional sndfileFileIOSupport libsndfile;

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-largefile"
    (enFlag "nasm" (
      elem targetSystem platforms.i686
      || elem targetSystem platforms.x86_64) null)
    "--enable-rpath"
    "--enable-cpml"
    "--disable-gtktest"
    "--disable-efence"
    "--disable-analyzer-hooks"
    "--enable-decoder"
    "--enable-frontend"
    "--disable-mp3x"
    "--enable-mp3rtp"
    "--enable-dynamic-frontends"
    "--enable-expopt=norm"
    "--disable-debug"
    (wtFlag "fileio" sndfileFileIOSupport sndfileFileIO)
  ];

  meta = with stdenv.lib; {
    description = "A high quality MPEG Audio Layer III (MP3) encoder";
    homepage  = http://lame.sourceforge.net;
    license   = licenses.lgpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
