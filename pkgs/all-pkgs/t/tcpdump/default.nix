{ stdenv
, fetchurl

, libcap-ng
, libpcap
, libsmi
, openssl
}:

stdenv.mkDerivation rec {
  name = "tcpdump-4.9.3";

  src = fetchurl {
    url = "http://www.tcpdump.org/release/${name}.tar.gz";
    multihash = "QmQ9guCZJLP4svYDYCwubnNsD8Bp6CRwp4hoLCuukrJX3w";
    hashOutput = false;
    sha256 = "2cd47cb3d460b6ff75f4a9940f594317ad456cfbf2bd2c8e5151e16559db6410";
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
      inherit (src) urls outputHash outputHashAlgo;
      fullOpts = {
        pgpsigUrl = map (n: "${n}.sig") src.urls;
        pgpKeyFingerprint = "1F16 6A57 42AB B9E0 249A  8D30 E089 DEF1 D9C1 5D0D";
      };
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
