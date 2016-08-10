{ stdenv
, fetchurl

, alsa-lib
, amrnb
, amrwb
, flac
, gsm
, ladspaH
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
    elem
    platforms
    wtFlag;
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
    ladspaH
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
    (wtFlag "png" (libpng != null) null)
    (wtFlag "ladspa" (ladspaH != null) null)
    #--with-ladspa-path
    (wtFlag "mad" (libmad != null) null)
    (wtFlag "id3tag" (libid3tag != null) null)
    (wtFlag "lame" (lame != null) null)
    # FIXME: add twolame support
    #(wtFlag "twolame" (twolame != null) null)
    "--without-twolame"
    (wtFlag "opusfile" (opusfile != null) null)
    (wtFlag "opus" (opus != null) null)
    (wtFlag "flac" (flac != null) null)
    (wtFlag "amrwb" (amrwb != null) null)
    (wtFlag "amrnb" (amrnb != null) null)
    (wtFlag "wavpack" (wavpack != null) null)
    #--with-sndio=dyn
    "--without-coreaudio" # Darwin
    (wtFlag "alsa" (alsa-lib != null) null)
    (wtFlag "ao" (libao != null) null)
    (wtFlag "pulseaudio" (pulseaudio_lib != null) null)
    #--with-waveaudio=dyn
    (wtFlag "sndfile" (libsndfile != null) null)
    #--with-oss=dyn
    "--without-oss"
    (wtFlag "sunaudio" (elem targetSystem platforms.illumos) null)
    #--with-mp3=dyn
    (wtFlag "gsm" (gsm != null) null)
    #--with-lpc10=dyn
  ];

  meta = with stdenv.lib; {
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
