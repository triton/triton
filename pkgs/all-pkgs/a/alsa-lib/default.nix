{ stdenv
, fetchurl
, lib
}:

stdenv.mkDerivation rec {
  name = "alsa-lib-1.1.3";

  src = fetchurl {
    url = "mirror://alsa/lib/${name}.tar.bz2";
    multihash = "QmP3rdGjhyguio1GYMMG71ercHSonmf2eAK5u8WCT2VsZM";
    sha256 = "71282502184c592c1a008e256c22ed0ba5728ca65e05273ceb480c70f515969c";
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
