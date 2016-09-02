{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "libmnl-1.0.4";

  src = fetchurl {
    url = "http://netfilter.org/projects/libmnl/files/${name}.tar.bz2";
    hashOutput = false;
    multihash = "QmbfB1C9Rcc5eLnMa3ZK8hv1vpTvmcB9b6B3a77ynPUgQD";
    sha256 = "171f89699f286a5854b72b91d06e8f8e3683064c5901fb09d954a9ab6f551f81";
  };

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrl = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprint = "C09D B206 3F1D 7034 BA61  52AD AB46 55A1 26D2 92E4";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    description = "minimalistic user-space library oriented to Netlink developers";
    homepage = http://netfilter.org/projects/libmnl/index.html;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
