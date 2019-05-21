{ stdenv
, fetchurl
}:

let
  version = "0.11.0";
in
stdenv.mkDerivation rec {
  name = "liburcu-${version}";

  src = fetchurl {
    url = "https://lttng.org/files/urcu/userspace-rcu-${version}.tar.bz2";
    multihash = "Qmc1R98UF5EN1wcBpUFjSgLrq2j1cekerAxBPupk8SQ7mn";
    hashOutput = false;
    sha256 = "1af5694c4f6266f4eba5eb4b832daee600d1e7055fce6da5d514d735d72eb3e7";
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
