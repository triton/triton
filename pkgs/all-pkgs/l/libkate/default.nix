{ stdenv
, fetchurl

, libogg
, libpng
}:

stdenv.mkDerivation rec {
  name = "libkate-0.4.1";

  src = fetchurl {
    url = "http://downloads.xiph.org/releases/kate/${name}.tar.gz";
    multihash = "QmVQst7y8YG25xDQt4n5bsABPRbJvthKhu6rzh8rMdStSm";
    sha256 = "0s3vr2nxfxlf1k75iqpp4l78yf4gil3f0v778kvlngbchvaq23n4";
  };

  buildInputs = [
    libogg
    libpng
  ];

  meta = with stdenv.lib; {
    description = "A library for encoding and decoding Kate streams";
    homepage = http://code.google.com/p/libkate;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
