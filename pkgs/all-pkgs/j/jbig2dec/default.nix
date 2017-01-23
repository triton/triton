{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "jbig2dec-0.13";

  src = fetchurl {
    url = "http://downloads.ghostscript.com/public/jbig2dec/${name}.tar.gz";
    multihash = "QmWnL9shuX5XeeJcbGb1ndjiUz66RnHSb9Fuqh5vCUm29M";
    sha256 = "5aaca0070992cc2e971e3bb2338ee749495613dcecab4c868fc547b4148f5311";
  };

  # Fix the lack of memento.h
  postInstall = ''
    cp memento.h $out/include
  '';

  meta = with stdenv.lib; {
    homepage = http://jbig2dec.sourceforge.net/;
    description = "Decoder implementation of the JBIG2 image compression format";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
