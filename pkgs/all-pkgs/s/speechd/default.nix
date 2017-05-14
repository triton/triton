{ stdenv
, autoconf
, fetchurl
, intltool
, lib
, libtool
, python3Packages

, alsa-lib
, dotconf
#, espeak
, flite
, glib
, libao
, libsndfile
#, nas
, pulseaudio_lib
}:

assert flite != null -> alsa-lib != null;

let
  inherit (lib)
    boolEn
    boolWt;

  version = "0.8.6";
in
stdenv.mkDerivation rec {
  name = "speech-dispatcher-${version}";

  src = fetchurl {
    url = "https://www.freebsoft.org/pub/projects/speechd/${name}.tar.gz";
    multihash = "QmPadN5cep1YdcjKt2PBPSSsBDTzAzzvFamUXRuhjvDTf7";
    sha256 = "c233dc3757c1f0d3676480d1052d42d88d18d29ab0cb0c8b5ce8edc3e7386ff8";
  };

  nativeBuildInputs = [
    autoconf
    intltool
    libtool
    python3Packages.pyxdg
  ];

  buildInputs = [
    alsa-lib
    dotconf
    #espeak
    flite
    glib
    libao
    libsndfile
    #nas
    pulseaudio_lib
    python3Packages.python
  ];

  postPatch = ''
    # speech-dispatcher underspecifies dependencies in AC_CHECK_LIB for
    # libflite checks.  Flite requires alsa to be present.
    sed -i configure \
      -e 's,-lm,-lm -lasound,'
  '';

  configureFlags = [
    "LDFLAGS=-L${flite}/lib/"
    "--enable-nls"
    "--${boolEn (python3Packages.python != null)}-python"
    /**/"--without-espeak"
    #"--${boolWt (espeak != null)}-espeak"
    /**/"--without-espeak-ng"
    #"--${boolWt (espeak != null)}-espeak-ng"
    "--${boolWt (flite != null)}-flite"
    "--without-ibmtts"
    "--without-ivona"
    "--without-pico"
    "--${boolWt (pulseaudio_lib != null)}-pulse"
    "--${boolWt (libao != null)}-libao"
    "--${boolWt (alsa-lib != null)}-alsa"
    "--without-oss"
    /**/"--without-nas"
    #"--${boolWt (nas != null)}-nas"
    #"--with-default-audio-method="
    #"--with-module-bindir"
  ];

  NIX_LDFLAGS = [
    # Fix flite linker errors due to underspecified dependnecies
    "-lasound"
  ];

  meta = with lib; {
    description = "Common interface to speech synthesis";
    homepage = http://www.freebsoft.org/speechd;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      x86_64-linux;
  };
}
