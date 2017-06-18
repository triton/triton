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
  name = "ncmpcpp-0.8";

  src = fetchurl {
    url = "https://rybczak.net/ncmpcpp/stable/${name}.tar.bz2";
    multihash = "QmYnG5Y5D6eSfeHZAprKw9g5ztTNnEbRcViandCmASYnRZ";
    sha256 = "2f0f2a1c0816119430880be6932e5eb356b7875dfa140e2453a5a802909f465a";
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
