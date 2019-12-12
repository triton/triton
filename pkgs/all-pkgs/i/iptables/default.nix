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
  name = "iptables-1.8.4";

  src = fetchurl {
    url = "http://www.netfilter.org/projects/iptables/files/${name}.tar.bz2";
    multihash = "QmNeVGGRsSQL5KtX4t179sB5hKwoAaeWhsQp4ZPPqAh8a8";
    hashOutput = false;
    sha256 = "993a3a5490a544c2cbf2ef15cf7e7ed21af1845baf228318d5c36ef8827e157c";
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
