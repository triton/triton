{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  version = "0.9.1";
  name = "liburcu-${version}";

  src = fetchurl {
    url = "http://lttng.org/files/urcu/userspace-rcu-${version}.tar.bz2";
    allowHashOutput = false;
    sha256 = "05c7znx1dfaqwf7klw8h02y3cjaqzg1w8kwmpb4rgv2vv7lpilpq";
  };

  passthru = {
    srcVerified = fetchurl {
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
