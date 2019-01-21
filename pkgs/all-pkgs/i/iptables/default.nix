{ stdenv
, bison
, fetchurl
, flex

, libmnl
, libnetfilter_conntrack
, libnfnetlink
, libnftnl
, libpcap
}:

stdenv.mkDerivation rec {
  name = "iptables-1.8.2";

  src = fetchurl {
    url = "http://www.netfilter.org/projects/iptables/files/${name}.tar.bz2";
    multihash = "QmZHJpWCopLMJ1pQKUt5tAipg7bmhPpJhw4YtZfomo6uMm";
    hashOutput = false;
    sha256 = "a3778b50ed1a3256f9ca975de82c2204e508001fc2471238c8c97f3d1c4c12af";
  };

  nativeBuildInputs = [
    bison
    flex
  ];

  buildInputs = [
    libmnl
    libnetfilter_conntrack
    libnfnetlink
    libnftnl
    libpcap
  ];

  configureFlags = [
    "--enable-devel"
    "--enable-libipq"
    "--enable-bpf-compiler"
    "--enable-nfsynproxy"
    "--enable-shared"
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
      fullOpts = {
        pgpsigUrl = map (n: "${n}.sig") src.urls;
        pgpKeyFingerprint = "C09D B206 3F1D 7034 BA61  52AD AB46 55A1 26D2 92E4";
      };
    };
  };

  meta = with stdenv.lib; {
    description = "A program to configure the Linux IP packet filtering ruleset";
    homepage = http://www.netfilter.org/projects/iptables/index.html;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
