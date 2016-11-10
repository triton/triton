{ stdenv
, fetchurl

, boost
, curl
, fftw_double
, icu
, libmpdclient
, ncurses
, readline
, taglib

, outputsSupport ? false # outputs screen
, clockSupport ? false # clock screen
}:

let
  inherit (stdenv.lib)
    boolEn
    boolWt;
in
stdenv.mkDerivation rec {
  name = "ncmpcpp-0.7.7";

  src = fetchurl {
    url = "https://rybczak.net/ncmpcpp/stable/${name}.tar.bz2";
    sha256 = "b7bcbec83b1f88cc7b21f196b10be09a27b430566c59f402df170163464d01ef";
  };

  buildInputs = [
    boost
    curl
    fftw_double
    icu
    libmpdclient
    ncurses
    readline
    taglib
  ];

  configureFlags = [
    "BOOST_LIB_SUFFIX="
    "--${boolEn outputsSupport}-outputs"
    "--${boolEn (fftw_double != null)}-visualizer"
    "--${boolEn clockSupport}-clock"
    "--enable-unicode"
    "--${boolWt (curl != null)}-curl"
    "--${boolWt (fftw_double != null)}-fftw"
    "--without-pdcurses"
    "--${boolWt (taglib != null)}-taglib"
  ];

  meta = with stdenv.lib; {
    description = "A featureful ncurses based MPD client";
    homepage = https://rybczak.net/ncmpcpp/;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
