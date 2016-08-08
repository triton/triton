{ stdenv
, fetchurl

, ffmpeg
, sox
}:

let
  version = "0.4.9";
in
stdenv.mkDerivation rec {
  name = "bs1770gain-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/bs1770gain/${name}.tar.gz";
    sha256 = "d839cc429c371b06589974bf5f54585d265ca2309b07d6cac07b2687a9b6499b";
  };

  buildInputs = [
    ffmpeg
    sox
  ];

  NIX_CFLAGS_COMPILE = "-Wno-error";
  CFLAGS = "-std=gnu89";

  meta = with stdenv.lib; {
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
