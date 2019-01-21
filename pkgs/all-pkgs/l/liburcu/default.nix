{ stdenv
, fetchurl
}:

let
  version = "0.10.2";
in
stdenv.mkDerivation rec {
  name = "liburcu-${version}";

  src = fetchurl {
    url = "https://lttng.org/files/urcu/userspace-rcu-${version}.tar.bz2";
    multihash = "QmYqRUfnbKPNZ2V3hmVqvy58vKzAD3iQatkKqWAwKXX8FK";
    hashOutput = false;
    sha256 = "b3f6888daf6fe02c1f8097f4a0898e41b5fe9975e121dc792b9ddef4b17261cc";
  };

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      inherit (src) urls outputHash outputHashAlgo;
      fullOpts = {
        md5Urls = map (n: "${n}.md5") src.urls;
        sha1Urls = map (n: "${n}.sha1") src.urls;
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
