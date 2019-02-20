{ stdenv
, fetchurl
, lib

, ffmpeg
, sox
}:

let
  version = "0.5.2";
in
stdenv.mkDerivation rec {
  name = "bs1770gain-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/bs1770gain/bs1770gain/${version}/${name}.tar.gz";
    sha256 = "73e5738786b57afb89582333ed18206fd2c6d5245717d3b24ace7f7670f9dedc";
  };

  buildInputs = [
    ffmpeg
    sox
  ];

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
