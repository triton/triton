{ stdenv
, fetchurl
}:

let
  version = "0.10.1";
in
stdenv.mkDerivation rec {
  name = "liburcu-${version}";

  src = fetchurl {
    url = "https://lttng.org/files/urcu/userspace-rcu-${version}.tar.bz2";
    multihash = "Qmcu4rhao4yvbSvcodKsreGa38P7SSzHSZuXiBjd1hsKoY";
    hashOutput = false;
    sha256 = "9c09220be4435dc27fcd22d291707b94b97f159e0c442fbcd60c168f8f79eb06";
  };

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      md5Urls = map (n: "${n}.md5") src.urls;
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
