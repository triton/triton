{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "libburn-1.4.4";

  src = fetchurl {
    url = "http://files.libburnia-project.org/releases/${name}.tar.gz";
    allowHashOutput = false;
    multihash = "QmWkE5BPAKKmQusdRBuFca7zNrGAJ3Yz4tYyiZA4a5Ee4K";
    sha256 = "1bf7040d6f1274acd868aec02a3c13241d0da8d9078067d228f2966ca40e7d14";
  };

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprint = "44BC 9FD0 D688 EB00 7C4D  D029 E9CB DFC0 ABC0 A854";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
