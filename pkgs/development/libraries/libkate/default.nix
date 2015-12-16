{ stdenv, fetchurl, libogg, libpng }:

stdenv.mkDerivation rec {
  name = "libkate-0.4.1";

  src = fetchurl {
    url = "http://libkate.googlecode.com/files/${name}.tar.gz";
    sha256 = "0s3vr2nxfxlf1k75iqpp4l78yf4gil3f0v778kvlngbchvaq23n4";
  };

  buildInputs = [ libogg libpng ];

  meta = {
    description = "A library for encoding and decoding Kate streams";
    longDescription = ''
      This is libkate, the reference implementation of a codec for the Kate
      bitstream format. Kate is a karaoke and text codec meant for encapsulation
      in an Ogg container. It can carry Unicode text, images, and animate
      them.'';
    homepage = http://code.google.com/p/libkate;
    maintainers = [ stdenv.lib.maintainers.urkud ];
  };
}
