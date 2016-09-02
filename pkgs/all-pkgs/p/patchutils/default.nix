{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "patchutils-0.3.4";

  src = fetchurl {
    url = "http://cyberelk.net/tim/data/patchutils/stable/${name}.tar.xz";
    hashOutput = false;
    multihash = "QmbaGXMUCXL2WueY4FMT5CwaygYK4AnDGiEY1YBTcXZVvb";
    sha256 = "cf55d4db83ead41188f5b6be16f60f6b76a87d5db1c42f5459d596e81dabe876";
  };

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprint = "4629 AFE9 60EC 20BE C12E  3104 B7C2 0D07 9491 EA63";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    description = "Tools to manipulate patch files";
    homepage = http://cyberelk.net/tim/software/patchutils;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
