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
  name = "iptables-1.6.0";

  src = fetchurl {
    url = "http://www.netfilter.org/projects/iptables/files/${name}.tar.bz2";
    hashOutput = false;
    multihash = "QmeAvUH8wfRoDEPRQj3N8qdwkrTQyUgZ4XJaCsMF8rp795";
    sha256 = "4bb72a0a0b18b5a9e79e87631ddc4084528e5df236bc7624472dcaa8480f1c60";
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
  parallelBuild = false;

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
