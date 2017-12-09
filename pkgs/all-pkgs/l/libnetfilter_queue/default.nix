{ stdenv
, fetchurl

, libmnl
, libnfnetlink
}:

stdenv.mkDerivation rec {
  name = "libnetfilter_queue-1.0.3";

  src = fetchurl {
    url = "http://netfilter.org/projects/libnetfilter_queue/files/${name}.tar.bz2";
    multihash = "QmaDZBqPMAzfwcTZ8tHNWm15inKsCZNBdSZ5XmSRt7BHYP";
    hashOutput = false;
    sha256 = "9859266b349d74c5b1fdd59177d3427b3724cd72a97c49cc2fffe3b55da8e774";
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
