{ stdenv
, fetchurl

, libcap-ng
, libpcap
, libsmi
, openssl
}:

stdenv.mkDerivation rec {
  name = "tcpdump-4.9.2";

  src = fetchurl {
    url = "http://www.tcpdump.org/release/${name}.tar.gz";
    multihash = "QmYgD5Mag91Qe4dd7HrknJQKcXE7JWMeGAZqrDD1ed8fDd";
    hashOutput = false;
    sha256 = "798b3536a29832ce0cbb07fafb1ce5097c95e308a6f592d14052e1ef1505fe79";
  };

  buildInputs = [
    libcap-ng
    libpcap
    libsmi
    openssl
  ];

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    # Don't instate privilege separation by default as
    # it is not seamless
    #"--with-user=nobody"
    #"--with-chroot=/var/empty"
  ];

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      pgpsigUrl = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprint = "1F16 6A57 42AB B9E0 249A  8D30 E089 DEF1 D9C1 5D0D";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    description = "Network sniffer";
    homepage = http://www.tcpdump.org/;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
