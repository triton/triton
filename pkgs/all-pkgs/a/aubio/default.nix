{ stdenv
, fetchurl
, lib
, python3
, waf

, fftw_double
, fftw_single
, ffmpeg
, jack2_lib
, libsndfile
}:

stdenv.mkDerivation rec {
  name = "aubio-0.4.9";

  src = fetchurl {
    url = "https://aubio.org/pub/${name}.tar.bz2";
    multihash = "QmYBrPimdabcJmFYECZkuU3CN9HEodenk7zZkBuRHypxRt";
    sha256 = "d48282ae4dab83b3dc94c16cf011bcb63835c1c02b515490e1883049c3d1f3da";
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

  postPatch = ''
    grep -q "'python" tests/wscript_build
    sed -i "s,'python,'${python3}/bin/python3," tests/wscript_build

    # Remove vendored waf
    rm -rv waflib/
  '';

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
    "--disable-tests"
    "--disable-examples"
  ];

  passthru = {
    srcVerification = fetchurl rec {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      fullOpts = {
        md5Urls = map (n: "${n}.md5") urls;
        sha256Urls = map (n: "${n}.sha256") urls;
        pgpsigUrls = map (n: "${n}.asc") urls;
        pgpKeyFingerprints = [
          # Paul Brossier
          "B88A 5072 D491 5AEC F81A  2434 6A49 B197 28AB DD92"
        ];
      };
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
