{ stdenv
, fetchurl
, lib
, waf

, fftw_double
, fftw_single
, ffmpeg
, jack2_lib
, libsndfile
}:

stdenv.mkDerivation rec {
  name = "aubio-0.4.6";

  src = fetchurl {
    url = "https://aubio.org/pub/aubio-0.4.6.tar.bz2";
    multihash = "QmZMM52LgnqXZi99b1SvPk2zWKziSvBMBkDzvcEWm36NHJ";
    sha256 = "bdc73be1f007218d3ea6d2a503b38a217815a0e2ccc4ed441f6e850ed5d47cfb";
  };

  nativeBuildInputs = [
    waf
  ];

  buildInputs = [
    fftw_double
    fftw_single
    ffmpeg
    jack2_lib
    libsndfile
  ];

  wafFlags = [
    "--disable-fftw3f"  # single
    "--enable-fftw3"  # double
    "--disable-intelipp"
    "--enable-jack"
    "--enable-sndfile"
    "--enable-avcodec"
    "--disable-samplerate"
    "--enable-double"
    #"--enable-atlas"
    "--enable-wavread"
    "--enable-wavwrite"
    "--disable-docs"

  ];

  wafUseVendored = true;

  passthru = {
    srcVerification = fetchurl rec {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      md5Urls = map (n: "${n}.md5") urls;
      sha256Urls = map (n: "${n}.sha256") urls;
      pgpsigUrls = map (n: "${n}.asc") urls;
      # Paul Brossier
      pgpKeyFingerprint = "B88A 5072 D491 5AEC F81A  2434 6A49 B197 28AB DD92";
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "Tool for extraction of annotations from audio signals";
    homepage = https://aubio.org/;
    license = licenses.free;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
