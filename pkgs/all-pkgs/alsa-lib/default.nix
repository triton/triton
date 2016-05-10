{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "alsa-lib-1.1.1";

  src = fetchurl {
    urls = [
      "ftp://ftp.alsa-project.org/pub/lib/${name}.tar.bz2"
      "http://alsa.cybermirror.org/lib/${name}.tar.bz2"
    ];
    sha256 = "8ac76c3144ed2ed49da7622ab65ac5415205913ccbedde877972383cbc234269";
  };

  patches = [
    ./alsa-plugin-conf-multilib.patch
  ];

  meta = with stdenv.lib; {
    homepage = http://www.alsa-project.org/;
    description = "ALSA, the Advanced Linux Sound Architecture libraries";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
