{ stdenv
, fetchurl
}:

let
  version = "4.8";

  tarballUrls = [
    "mirror://kernel/software/network/ethtool/ethtool-${version}.tar"
  ];
in
stdenv.mkDerivation rec {
  name = "ethtool-${version}";

  src = fetchurl {
    urls = map (n: "${n}.xz") tarballUrls;
    hashOutput = false;
    sha256 = "403dfe288e2d8031eab0be3f5d0ca9128e120d61c52c3dc434474fa026eb4a43";
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

  meta = with stdenv.lib; {
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
