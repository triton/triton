{ stdenv
, automake
, fetchurl
, lib

, libpcap
, ncurses
}:

stdenv.mkDerivation rec {
  name = "iftop-1.0pre4";

  src = fetchurl {
    url = "http://ex-parrot.com/pdw/iftop/download/${name}.tar.gz";
    multihash = "QmafxU7PamngJiT3sV2L3WNG3zT3hgagX9ESKNfCvYiXf9";
    sha256 = "f733eeea371a7577f8fe353d86dd88d16f5b2a2e702bd96f5ffb2c197d9b4f97";
  };

  buildInputs = [
    libpcap
    ncurses
  ];

  preConfigure = ''
    cp -v ${automake}/share/automake*/config.{sub,guess} config
  '';

  meta = with lib; {
    description = "Display bandwidth usage on a network interface";
    homepage = http://ex-parrot.com/pdw/iftop/;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      x86_64-linux;
  };
}
