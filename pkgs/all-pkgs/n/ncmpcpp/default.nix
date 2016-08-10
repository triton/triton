{ stdenv
, fetchurl

# Required
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
    enFlag
    wtFlag;
in

stdenv.mkDerivation rec {
  name = "ncmpcpp-0.7.4";

  src = fetchurl {
    url = "http://ncmpcpp.rybczak.net/stable/${name}.tar.bz2";
    sha256 = "d70425f1dfab074a12a206ddd8f37f663bce2bbdc0a20f7ecf290ebe051f1e63";
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
    (enFlag "outputs" outputsSupport null)
    (enFlag "visualizer" (fftw_double != null) null)
    (enFlag "clock" clockSupport null)
    "--enable-unicode"
    (wtFlag "curl" (curl != null) null)
    (wtFlag "fftw" (fftw_double != null) null)
    "--without-pdcurses"
    (wtFlag "taglib" (taglib != null) null)
  ];

  meta = with stdenv.lib; {
    description = "A featureful ncurses based MPD client inspired by ncmpc";
    homepage = http://ncmpcpp.rybczak.net/;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
