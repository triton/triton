{ stdenv
, fetchurl
, lib
}:

let
  version = "5.1";

  tarballUrls = [
    "mirror://kernel/software/network/ethtool/ethtool-${version}.tar"
  ];
in
stdenv.mkDerivation rec {
  name = "ethtool-${version}";

  src = fetchurl {
    urls = map (n: "${n}.xz") tarballUrls;
    hashOutput = false;
    sha256 = "65feac1fec6565290b7784b2efc925dee900a9b11202ce7c6c30a967c3da3387";
  };

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
      fullOpts = {
        pgpsigUrls = map (n: "${n}.sign") tarballUrls;
        pgpDecompress = true;
        pgpKeyFingerprints = [
          # Ben Hutchings
          "AC2B 29BD 34A6 AFDD B3F6  8F35 E7BF C8EC 9586 1109"
          # John W. Linville
          "CE4A 4D08 0F0D 304F 23B9  EBDD 972D 5BF4 DC61 3806"
        ];
      };
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
