{ stdenv
, fetchurl

, gnutls
, zlib
}:

stdenv.mkDerivation rec {
  name = "librelp-1.2.14";

  # SHA256 found at http://www.librelp.com/
  src = fetchurl {
    url = "http://download.rsyslog.com/librelp/${name}.tar.gz";
    multihash = "QmbTcR2p7q3ZwSb4jvSAnBAQX6DMuBked8HhGBbgd88aUa";
    hashOutput = false;
    sha256 = "11f6241a4336358a33bfdadd43ef299e8258db0a5243d0c164499c6b85ae5955";
  };

  buildInputs = [
    gnutls
    zlib
  ];

  meta = with stdenv.lib; {
    homepage = http://www.librelp.com/;
    description = "a reliable logging library";
    license = licenses.gpl2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
