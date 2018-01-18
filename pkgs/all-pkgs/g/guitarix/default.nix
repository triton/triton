{ stdenv
, fetchurl
, gettext
, intltool
, lib
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
, gtk_2
, gtkmm_2
, jack2_lib
, ladspa-sdk
, lrdf
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

let
  inherit (stdenv.lib)
    optional;
in
stdenv.mkDerivation rec {
  name = "guitarix-${version}";
  version = "0.35.2";

  src = fetchurl {
    url = "mirror://sourceforge/guitarix/guitarix/guitarix2-${version}.tar.xz";
    sha256 = "77dc3bd0a88538efaecee910e6a27955b2077699894eb99e97219407655343e2";
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
    gtk_2
    gtkmm_2
    jack2_lib
    ladspa-sdk
    lrdf
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

  postPatch = ''
    patchShebangs ./waf
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

  configurePhase = ''
    ./waf configure --prefix=$out $configureFlags
  '';

  NIX_CFLAGS_COMPILE = [
    "-I${eigen}/include/eigen3"
  ];

  buildPhase = ''
    ./waf build
  '';

  installPhase = ''
    ./waf install
  '';

  preFixup = ''
    wrapProgram $out/bin/guitarix \
      --set 'GDK_PIXBUF_MODULE_FILE' '${gdk-pixbuf.loaders.cache}' \
      --prefix 'PATH' : "${qjackctl}/bin"
  '';

  meta = with lib; {
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
