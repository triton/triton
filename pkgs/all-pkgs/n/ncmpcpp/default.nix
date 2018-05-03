{ stdenv
, fetchurl
, lib

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
  inherit (lib)
    boolEn
    boolWt;
in
stdenv.mkDerivation rec {
  name = "ncmpcpp-0.8.2";

  src = fetchurl {
    url = "https://rybczak.net/ncmpcpp/stable/${name}.tar.bz2";
    multihash = "QmTftWxcupc7AzmvQJD9zT4uNMM86zeFQVnq3QouUjCaJV";
    sha256 = "650ba3e8089624b7ad9e4cc19bc1ac6028edb7523cc111fa1686ea44c0921554";
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

  meta = with lib; {
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
