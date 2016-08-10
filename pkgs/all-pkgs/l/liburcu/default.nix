{ stdenv
, fetchurl
}:

let
  version = "0.9.2";
in
stdenv.mkDerivation rec {
  name = "liburcu-${version}";

  src = fetchurl {
    url = "http://lttng.org/files/urcu/userspace-rcu-${version}.tar.bz2";
    allowHashOutput = false;
    sha256 = "8f7fa313b1e0a3f742cea24ce63a39c0efe63e615a769e2961e55bd2663ecaa3";
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
