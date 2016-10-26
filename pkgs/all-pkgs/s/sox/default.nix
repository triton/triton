{ stdenv
, fetchurl
, lib

, alsa-lib
, amrnb
, amrwb
, flac
, gsm
, ladspa-sdk
, lame
, libao
, libid3tag
, libmad
, libogg
, libpng
, libsndfile
, libtool
, libvorbis
, opus
, opusfile
, pulseaudio_lib
#, twolame
, wavpack
, zlib
}:

let
  inherit (stdenv)
    targetSystem;
  inherit (stdenv.lib)
    boolWt
    elem
    platforms;
in
stdenv.mkDerivation rec {
  name = "sox-14.4.2";

  src = fetchurl {
    url = "mirror://sourceforge/sox/${name}.tar.gz";
    sha256 = "b45f598643ffbd8e363ff24d61166ccec4836fea6d3888881b8df53e3bb55f6c";
  };

  buildInputs = [
    alsa-lib
    amrnb
    amrwb
    flac
    gsm
    ladspa-sdk
    lame
    libao
    libid3tag
    libmad
    libogg
    libpng
    libsndfile
    # libltdl is used at runtime to load plugin libraries
    libtool
    libvorbis
    opus
    opusfile
    pulseaudio_lib
    #twolame
    wavpack
    zlib
  ];

  configureFlags = [
    "--with-distro=Triton"
    #"--with-magic"
    "--${boolWt (libpng != null)}-png"
    "--${boolWt (ladspa-sdk != null)}-ladspa"
    #--with-ladspa-path
    "--${boolWt (libmad != null)}-mad"
    "--${boolWt (libid3tag != null)}-id3tag"
    "--${boolWt (lame != null)}-lame"
    #"--${boolWt (twolame != null)}-twolame"
    /**/"--without-twolame"
    "--${boolWt (opusfile != null)}-opusfile"
    "--${boolWt (opus != null)}-opus"
    "--${boolWt (flac != null)}-flac"
    "--${boolWt (amrwb != null)}-amrwb"
    "--${boolWt (amrnb != null)}-amrnb"
    "--${boolWt (wavpack != null)}-wavpack"
    #--with-sndio=dyn
    "--without-coreaudio" # Darwin
    "--${boolWt (alsa-lib != null)}-alsa"
    "--${boolWt (libao != null)}-ao"
    "--${boolWt (pulseaudio_lib != null)}-pulseaudio"
    #--with-waveaudio=dyn
    "--${boolWt (libsndfile != null)}-sndfile"
    "--without-oss"
    "--${boolWt (elem targetSystem platforms.illumos)}-sunaudio"
    #--with-mp3=dyn
    "--${boolWt (gsm != null)}-gsm"
    #--with-lpc10=dyn
  ];

  meta = with lib; {
    description = "Audio sample rate converter";
    homepage = http://sox.sourceforge.net/;
    license =
      if amrnb != null || amrwb != null then
        licenses.unfreeRedistributable
      else
        licenses.gpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
