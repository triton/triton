{ stdenv
, fetchurl

, libcap-ng
, libpcap
, libsmi
, openssl
}:

stdenv.mkDerivation rec {
  name = "tcpdump-4.9.1";

  src = fetchurl {
    url = "http://www.tcpdump.org/release/${name}.tar.gz";
    multihash = "QmVBCZsksUMay9YXVuZTBU1tFWvm2RucnWrG8CHxKMJgdm";
    hashOutput = false;
    sha256 = "f9448cf4deb2049acf713655c736342662e652ef40dbe0a8f6f8d5b9ce5bd8f3";
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
