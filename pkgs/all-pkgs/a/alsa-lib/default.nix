{ stdenv
, fetchurl
, lib
}:

stdenv.mkDerivation rec {
  name = "alsa-lib-1.1.4";

  src = fetchurl {
    url = "mirror://alsa/lib/${name}.tar.bz2";
    multihash = "QmaVX3uLWFbeRGppk9YeD9YusYAMMM2d9UV6h49Xbqn311";
    sha256 = "82f50a09487079755d93e4c9384912196995bade6280bce9bfdcabf094bfb515";
  };

  patches = [
    ./alsa-plugin-conf-multilib.patch
  ];

  meta = with lib; {
    description = "ALSA, the Advanced Linux Sound Architecture libraries";
    homepage = http://www.alsa-project.org/;
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
