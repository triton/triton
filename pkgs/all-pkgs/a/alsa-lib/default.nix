{ stdenv
, fetchurl
, lib
}:

stdenv.mkDerivation rec {
  name = "alsa-lib-1.1.5";

  src = fetchurl {
    url = "mirror://alsa/lib/${name}.tar.bz2";
    multihash = "QmUUtUSuJV7QACXoXr3vMGYaYqrnKqdEJwwabjqGksd6CU";
    sha256 = "f4f68ad3c6da36b0b5241ac3c798a7a71e0e97d51f972e9f723b3f20a9650ae6";
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
