{ stdenv
, fetchurl

, fftw_double
, libsndfile
}:

let
  inherit (stdenv.lib)
    enFlag;
in
stdenv.mkDerivation rec {
  name = "libsamplerate-0.1.8";

  src = fetchurl {
    url = "http://www.mega-nerd.com/SRC/${name}.tar.gz";
    sha256 = "01hw5xjbjavh412y63brcslj5hi9wdgkjd3h9csx5rnm8vglpdck";
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
    (enFlag "fftw" (fftw_double != null) null)
    "--enable-cpu-clip"
    (enFlag "sndfile" (libsndfile != null) null)
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
