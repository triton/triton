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
  name = "iptables-1.6.1";

  src = fetchurl {
    url = "http://www.netfilter.org/projects/iptables/files/${name}.tar.bz2";
    multihash = "QmXwK9tY7EFGt1Xkj3LC9Z5MytDMzPvKQtWhL7ux2BS4b2";
    hashOutput = false;
    sha256 = "0fc2d7bd5d7be11311726466789d4c65fb4c8e096c9182b56ce97440864f0cf5";
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

  # Sometimes breaks building nft.c before xtables-config-parser.h
  buildParallel = false;

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrl = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprint = "C09D B206 3F1D 7034 BA61  52AD AB46 55A1 26D2 92E4";
      inherit (src) urls outputHash outputHashAlgo;
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
