{ stdenv
, fetchurl
}:

let
  version = "4.5";

  tarballUrls = [
    "mirror://kernel/software/network/ethtool/ethtool-${version}.tar"
  ];
in
stdenv.mkDerivation rec {
  name = "ethtool-${version}";

  src = fetchurl {
    urls = map (n: "${n}.xz") tarballUrls;
    allowHashOutput = false;
    sha256 = "bb2834332c5ac7f5bbe1c9f78f4fa851e4a3fe6397b124d58467c9ccee9fca3b";
  };

  passthru = {
    srcVerified = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.sign") tarballUrls;
      pgpDecompress = true;
      pgpKeyId = "95861109";
      pgpKeyFingerprint = "AC2B 29BD 34A6 AFDD B3F6  8F35 E7BF C8EC 9586 1109";
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
