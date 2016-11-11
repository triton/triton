{ stdenv
, fetchurl

, libcap-ng
, libpcap
, libsmi
, openssl
}:

stdenv.mkDerivation rec {
  name = "tcpdump-4.8.1";

  src = fetchurl {
    url = "http://www.tcpdump.org/release/${name}.tar.gz";
    hashOutput = false;
    multihash = "Qmd8ChjWp9yAuc44XZiWQ3sUWynfj8PJe45hrNsHvqeQvj";
    sha256 = "20e4341ec48fcf72abcae312ea913e6ba6b958617b2f3fb496d51f0ae88d831c";
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
    "--with-user=nobody"
    "--with-chroot=/var/empty"
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
