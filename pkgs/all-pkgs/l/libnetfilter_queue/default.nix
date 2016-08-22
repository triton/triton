{ stdenv
, fetchurl

, libmnl
, libnfnetlink
}:

stdenv.mkDerivation rec {
  name = "libnetfilter_queue-1.0.2";

  src = fetchurl {
    url = "http://netfilter.org/projects/libnetfilter_queue/files/${name}.tar.bz2";
    allowHashOutput = false;
    multihash = "Qme5Q661vr7KKaaRcz1VgpgBKMK8wwmpm6r7vAzpHNTLyS";
    sha256 = "0chsmj9ky80068vn458ijz9sh4sk5yc08dw2d6b8yddybpmr1143";
  };

  buildInputs = [
    libmnl
    libnfnetlink
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrl = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprint = "C09D B206 3F1D 7034 BA61  52AD AB46 55A1 26D2 92E4";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    homepage = "http://www.netfilter.org/projects/libnetfilter_queue/";
    description = "userspace API to packets queued by the kernel packet filter";
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
