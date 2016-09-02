{ stdenv
, fetchurl

, alsa-lib
, flac
, libogg
, libvorbis
}:

let
  inherit (stdenv.lib)
    enFlag
    optionalString;
in

stdenv.mkDerivation rec {
  name = "libsndfile-1.0.27";

  src = fetchurl {
    url = "http://www.mega-nerd.com/libsndfile/files/${name}.tar.gz";
    hashOutput = false;
    multihash = "QmRYMLHB4bmnaxgqgBdNd1wjqU6PPv9rUBCmeDVMSqwGRv";
    sha256 = "1h7s61nhf7vklh9sdsbbqzb6x287q4x4j1jc5gmjragl4wprb4d3";
  };

  buildInputs = [
    alsa-lib
    flac
    libogg
    libvorbis
  ];

  configureFlags = [
    "--disable-experimental"
    "--disable-werror"
    "--disable-stack-smash-protection"
    "--disable-gcc-pipe"
    #"--enable-cpu-clip"
    "--disable-sqlite"
    "--enable-alsa"
    "--enable-external-libs"
    "--disable-octave"
    "--disable-test-coverage"
    "--without-octave"
    "--without-mkoctfile"
    "--without-octave-config"
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      pgpKeyFingerprint = "E932 D120 BC2A EC44 4E55  8F01 06CA 9F5D 1DCF 2659";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    description = "A C library for reading and writing files containing sampled sound";
    homepage = http://www.mega-nerd.com/libsndfile/;
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [
      codyopel
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
