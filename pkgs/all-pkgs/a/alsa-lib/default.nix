{ stdenv
, fetchurl
, lib
}:

stdenv.mkDerivation rec {
  name = "alsa-lib-1.1.7";

  src = fetchurl {
    url = "mirror://alsa/lib/${name}.tar.bz2";
    multihash = "QmVVzgHiV5hYr8YHBHSHca5apWz94TgCJcRRgNFNnfJrMb";
    hashOutput = false;
    sha256 = "9d6000b882a3b2df56300521225d69717be6741b71269e488bb20a20783bdc09";
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
