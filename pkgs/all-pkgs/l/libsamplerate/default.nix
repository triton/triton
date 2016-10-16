{ stdenv
, fetchurl

, fftw_double
, libsndfile
}:

let
  inherit (stdenv.lib)
    boolEn;
in
stdenv.mkDerivation rec {
  name = "libsamplerate-0.1.9";

  src = fetchurl {
    url = "http://www.mega-nerd.com/SRC/${name}.tar.gz";
    multihash = "QmWDo6utmhKrmLrQCgKX5xstVJz4fBJinjrTfhZznRALzZ";
    sha256 = "0a7eb168e2f21353fb6d84da152e4512126f7dc48ccb0be80578c565413444c1";
  };

  buildInputs = [
    fftw_double
    libsndfile
  ];

  configureFlags = [
    # Flag is not a proper boolean
    #"--disable-gcc-werror"
    "--enable-gcc-pipe"
    "--enable-gcc-opt"
    "--${boolEn (fftw_double != null)}-fftw"
    "--enable-cpu-clip"
    "--${boolEn (libsndfile != null)}-sndfile"
  ];

  meta = with stdenv.lib; {
    description = "Audio sample rate converter";
    homepage = http://www.mega-nerd.com/SRC/;
    licenses = with licenses; [
      gpl3
    ];
    maintainers = with maintainers; [
      codyopel
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
