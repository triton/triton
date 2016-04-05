{ stdenv
, fetchurl
#, alac-decoder
, flac
#, mac
#, shorten
, sox
, wavpack
}:

stdenv.mkDerivation rec {
  version = "3.0.10";
  name = "shntool-${version}";

  src = fetchurl {
    url = "http://www.etree.org/shnutils/shntool/dist/src/${name}.tar.gz";
    sha256 = "74302eac477ca08fb2b42b9f154cc870593aec8beab308676e4373a5e4ca2102";
  };

  buildInputs = [
    #alac-decoder
    flac
    #mac
    #shorten
    sox
    wavpack
  ];

  meta = with stdenv.lib; {
    description = "Multi-purpose WAVE data processing and reporting utility";
    homepage = http://www.etree.org/shnutils/shntool/;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
