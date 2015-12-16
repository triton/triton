{ stdenv, fetchurl, autoreconfHook }:

stdenv.mkDerivation rec {
  name = "jbig2dec-0.12";

  src = fetchurl {
    url = "http://downloads.ghostscript.com/public/jbig2dec/${name}.tar.gz";
    sha256 = "1w7bwpibw96srv8aay950rrcg002fhdlm3f6qfifjipffp6g5idw";
  };

  nativeBuildInputs = [ autoreconfHook ];

  # Fix the lack of memento.h
  postInstall = ''
    cp memento.h $out/include
  '';

  meta = {
    homepage = http://jbig2dec.sourceforge.net/;
    description = "Decoder implementation of the JBIG2 image compression format";
    license = stdenv.lib.licenses.gpl2Plus;
  };
}
