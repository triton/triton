{ stdenv
, fetchgit
, fetchurl
, gettext
, intltool
, makeWrapper
, python

, atkmm
, avahi
, bluez
, boost
, eigen
, fftw
, gdk-pixbuf
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
, pangomm
, qjackctl
, serd
, sord
, sratom
, zita-convolver
, zita-resampler

# Enable support for native CPU extensions
, optimizationSupport ? false
}:

with {
  inherit (stdenv.lib)
    optional;
};

stdenv.mkDerivation rec {
  name = "guitarix-${version}";
  #version = "0.34.0";
  version = "2016-02-14";

  /*src = fetchurl {
    url = "mirror://sourceforge/guitarix/guitarix2-${version}.tar.bz2";
    sha256 = "0pamaq8iybsaglq6y1m1rlmz4wgbs2r6m24bj7x4fwg4grjvzjl8";
  };*/
  # Support for disabling webkitgtk will be in the 0.35.0 release
  src = fetchgit {
    url = "http://git.code.sf.net/p/guitarix/git";
    rev = "4682d8ca6d9c76d3b1bc8da489ded7d043d27d65";
    sha256 = "0j3x64llfy51szmysn83fgs79qj8sz20rgiq59kwc1qm081z1hvm";
  };

  nativeBuildInputs = [
    gettext
    intltool
    makeWrapper
    python
  ];

  buildInputs = [
    atkmm
    avahi
    #bluez
    boost
    gdk-pixbuf
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
    pangomm
    serd
    sord
    sratom
    zita-convolver
    zita-resampler
  ];

  /* remove for 0.35.0 release */
  postUnpack = ''
    sourceRoot=$sourceRoot/trunk
  '';

  postPatch = ''
    patchShebangs waf
  '';

  configureFlags = [
    "--nocache"
    "--shared-lib"
    "--lib-dev"
    "--no-ldconfig"
    "--no-desktop-update"
    "--enable-nls"
    "--no-faust"
  ] ++ optional optimizationSupport "--optimization";

  NIX_CFLAGS_COMPILE = [
    #"-std=c++11"
    "-I${eigen}/include/eigen3"
  ];

  configurePhase = ''
      ./waf configure --prefix=$out $configureFlags
    '';

  buildPhase = ''
    ./waf build
  '';

  installPhase = ''
    ./waf install
  '';

  preFixup = ''
    wrapProgram $out/bin/guitarix \
      --prefix 'PATH' : "${qjackctl}/bin"
  '';

  meta = with stdenv.lib; {
    description = "A virtual guitar amplifier";
    homepage = http://guitarix.sourceforge.net/;
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
