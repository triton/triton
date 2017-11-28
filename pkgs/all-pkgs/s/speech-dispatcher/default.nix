{ stdenv
, autoconf
, fetchurl
, intltool
, lib
, libtool
, python3Packages
, texinfo

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

  version = "0.8.8";
in
stdenv.mkDerivation rec {
  name = "speech-dispatcher-${version}";

  src = fetchurl {
    url = "http://www.freebsoft.org/pub/projects/speechd/${name}.tar.gz";
    multihash = "QmXBDrN2CUrQ8L64T8xTqrX3z8TJgKbj4MDFfydN86ajqh";
    sha256 = "3c2a89800d73403192b9d424a604f0e614c58db390428355a3b1c7c401986cf3";
  };

  nativeBuildInputs = [
    autoconf
    intltool
    libtool
    python3Packages.pyxdg
    texinfo
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
