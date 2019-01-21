{ stdenv
, fetchurl
, lib
}:

stdenv.mkDerivation rec {
  name = "alsa-lib-1.1.8";

  src = fetchurl {
    url = "mirror://alsa/lib/${name}.tar.bz2";
    multihash = "QmS2Yu4mDJ7h8NFFji61XmNAUJ3i8L5TrRsAzfK9kE8zZ7";
    hashOutput = false;
    sha256 = "3cdc3a93a6427a26d8efab4ada2152e64dd89140d981f6ffa003e85be707aedf";
  };

  patches = [
    ./alsa-plugin-conf-multilib.patch
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
      fullOpts = {
        insecureHashOutput = true;
      };
    };
  };

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
