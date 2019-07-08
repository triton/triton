{ stdenv
, fetchurl
}:

let
  version = "0.11.1";
in
stdenv.mkDerivation rec {
  name = "liburcu-${version}";

  src = fetchurl {
    url = "https://lttng.org/files/urcu/userspace-rcu-${version}.tar.bz2";
    multihash = "QmaG2YwLkf7THJy2Px6x8G3DqyjAMAY4J8213w946pVRdc";
    hashOutput = false;
    sha256 = "92b9971bf3f1c443edd6c09e7bf5ff3b43531e778841f16377a812c8feeb3350";
  };

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      inherit (src) urls outputHash outputHashAlgo;
      fullOpts = {
        md5Urls = map (n: "${n}.md5") src.urls;
        sha256Urls = map (n: "${n}.sha256") src.urls;
        pgpsigUrls = map (n: "${n}.asc") src.urls;
        pgpKeyFingerprint = "2A0B 4ED9 15F2 D3FA 45F5  B162 1728 0A97 8118 6ACF";
      };
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
