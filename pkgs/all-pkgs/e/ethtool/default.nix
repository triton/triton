{ stdenv
, fetchurl
, lib
}:

let
  version = "4.15";

  tarballUrls = [
    "mirror://kernel/software/network/ethtool/ethtool-${version}.tar"
  ];
in
stdenv.mkDerivation rec {
  name = "ethtool-${version}";

  src = fetchurl {
    urls = map (n: "${n}.xz") tarballUrls;
    hashOutput = false;
    sha256 = "71f7fd32483ffdc7c6c4d882e230714eb101df0a46cbe396dbeb8ac78f1ef91a";
  };

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.sign") tarballUrls;
      pgpDecompress = true;
      pgpKeyFingerprints = [
        # Ben Hutchings
        "AC2B 29BD 34A6 AFDD B3F6  8F35 E7BF C8EC 9586 1109"
        # John W. Linville
        "CE4A 4D08 0F0D 304F 23B9  EBDD 972D 5BF4 DC61 3806"
      ];
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with lib; {
    description = "Utility for controlling network drivers and hardware";
    homepage = https://www.kernel.org/pub/software/network/ethtool/;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
