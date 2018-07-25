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
  name = "iptables-1.8.0";

  src = fetchurl {
    url = "http://www.netfilter.org/projects/iptables/files/${name}.tar.bz2";
    multihash = "QmevSzREm6thrEqLFEfeVdk1yi6VET5Lp8jt2W3TcNrnyJ";
    hashOutput = false;
    sha256 = "c4cbfa187c4296e4bc2e347ebbc21e309def7274773f20f0df0b8feaf7e8de50";
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
