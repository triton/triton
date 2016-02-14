{ stdenv, fetchurl
, gettext
, intltool
, makeWrapper
, pkgconfig
, python

, avahi
, bluez
, boost
, eigen
, fftw
, glib
, glibmm
, gtk2
, gtkmm_2
, libjack2
, ladspaH
, librdf
, librsvg
, libsndfile
, lilv
, lv2
, qjackctl
, serd
, sord
, sratom
, webkitgtk_2_4_gtk2
, zita-convolver
, zita-resampler
, optimizationSupport ? false # Enable support for native CPU extensions
}:

let
  inherit (stdenv.lib) optional;
in

stdenv.mkDerivation rec {
  name = "guitarix-${version}";
  version = "0.34.0";

  src = fetchurl {
    url = "mirror://sourceforge/guitarix/guitarix2-${version}.tar.bz2";
    sha256 = "0pamaq8iybsaglq6y1m1rlmz4wgbs2r6m24bj7x4fwg4grjvzjl8";
  };

  NIX_CFLAGS_COMPILE = [
    #"-std=c++11"
    "-I${eigen}/include/eigen3"
  ];

  nativeBuildInputs = [
    gettext
    intltool
    pkgconfig
    python
  ];

  buildInputs = [
    avahi
    #bluez
    boost
    eigen
    fftw
    glib
    glibmm
    gtk2
    gtkmm_2
    libjack2
    ladspaH
    librdf
    librsvg
    libsndfile
    lilv
    lv2
    serd
    sord
    sratom
    webkitgtk_2_4_gtk2
    zita-convolver
    zita-resampler
  ];

  configureFlags = [
    "--nocache"
    "--shared-lib"
    "--lib-dev"
    "--no-ldconfig"
    "--no-desktop-update"
    "--enable-nls"
    "--no-faust" # todo: find out why --faust doesn't work
  ] ++ optional optimizationSupport "--optimization";

  configurePhase = ''
    python waf configure --prefix=$out $configureFlags
  '';

  buildPhase = ''
    python waf build
  '';

  installPhase = ''
    python waf install
  '';

  preFixup = ''
    gtk3AppsWrapperArgs+=("--prefix PATH : ${qjackctl}/bin")
  '';

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "A virtual guitar amplifier";
    homepage = http://guitarix.sourceforge.net/;
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
