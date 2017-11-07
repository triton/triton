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
  name = "ncmpcpp-0.8.1";

  src = fetchurl {
    url = "https://rybczak.net/ncmpcpp/stable/${name}.tar.bz2";
    multihash = "QmbVKv5zNT9cB8WHNiN54pF9rLdTMHbiV1QoBRXnDrwcoV";
    sha256 = "4df9570a1db4ba2dc9b759aab88b283c00806fb5d2bce5f5d27a2eb10e6888ff";
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
