{ stdenv
, fetchurl
, lib
}:

stdenv.mkDerivation rec {
  name = "alsa-lib-1.1.4.1";

  src = fetchurl {
    url = "mirror://alsa/lib/${name}.tar.bz2";
    multihash = "QmcC8xCtnwT2HaCLzoVgMKk46NwBuZeU9VqY6rAoJCT6PT";
    sha256 = "91bb870c14d1c7c269213285eeed874fa3d28112077db061a3af8010d0885b76";
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
