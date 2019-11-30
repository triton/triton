{ stdenv
, bison
, fetchurl
, flex

, dbus
, libnl
, rdma-core
}:

stdenv.mkDerivation rec {
  name = "libpcap-1.9.1";

  src = fetchurl {
    url = "http://www.tcpdump.org/release/${name}.tar.gz";
    multihash = "QmcpcQsByLDkmbWdpaVB9Rf5Lr2CbFbpqSmTYveqi33dm4";
    hashOutput = false;
    sha256 = "635237637c5b619bcceba91900666b64d56ecb7be63f298f601ec786ce087094";
  };

  nativeBuildInputs = [
    bison
    flex
  ];

  buildInputs = [
    dbus
    libnl
    rdma-core
  ];

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
  ];

  preBuild = ''
    export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE -I$(echo "${libnl}"/include/*)"
  '';

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
    homepage = http://www.tcpdump.org;
    description = "Packet Capture Library";
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
