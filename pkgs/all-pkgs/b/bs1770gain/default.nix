{ stdenv
, fetchurl
, lib

, ffmpeg
, sox
}:

let
  version = "0.4.12";
in
stdenv.mkDerivation rec {
  name = "bs1770gain-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/bs1770gain/bs1770gain/${version}/${name}.tar.gz";
    sha256 = "cafc5440cf4940939c675e98c8dbeb839f4965d60f74270a37d4ee70559b3a59";
  };

  buildInputs = [
    ffmpeg
    sox
  ];

  postPatch = ''
    #ls -al ; return 1
    sed -i libffsox-2/ffsox_frame_writer.c \
      -i libffsox-2/ffsox_frame.c \
      -i libffsox-2/ffsox_packet_writer.c \
      -e 's/CODEC_FLAG_GLOBAL_HEADER/AV_CODEC_FLAG_GLOBAL_HEADER/g' \
      -e 's/CODEC_CAP_VARIABLE_FRAME_SIZE/AV_CODEC_CAP_VARIABLE_FRAME_SIZE/'
  '';

  meta = with lib; {
    description = "A audio/video loudness scanner implementing ITU-R BS.1770";
    homepage = "http://bs1770gain.sourceforge.net/";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
