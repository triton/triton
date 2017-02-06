{ stdenv
, fetchurl
}:

let
  version = "0.9.3";
in
stdenv.mkDerivation rec {
  name = "liburcu-${version}";

  src = fetchurl {
    url = "http://lttng.org/files/urcu/userspace-rcu-${version}.tar.bz2";
    multihash = "QmYYrSQQYiHAzpo9BN4e88otE3F4ETRgbmvQC656856c2G";
    hashOutput = false;
    sha256 = "1bce32e6a6c967fef6d37adaadf33df19878d69673f9ef9d3f2470e0c6ed4006";
  };

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      sha1Urls = map (n: "${n}.sha1") src.urls;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      pgpKeyFingerprint = "2A0B 4ED9 15F2 D3FA 45F5  B162 1728 0A97 8118 6ACF";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    description = "Userspace RCU (read-copy-update) library";
    homepage = http://lttng.org/urcu;
    license = licenses.lgpl21Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = platforms.linux;
  };

}
