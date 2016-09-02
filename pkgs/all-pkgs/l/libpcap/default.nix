{ stdenv
, bison
, fetchurl
, flex

, dbus
, libnl
, libusb
}:

stdenv.mkDerivation rec {
  name = "libpcap-1.7.4";

  src = fetchurl {
    url = "http://www.tcpdump.org/release/${name}.tar.gz";
    hashOutput = false;
    multihash = "QmNLp64sSvuvbrmFDPBhrsiKjr63q2qXPpCpYGcwRvn4uU";
    sha256 = "7ad3112187e88328b85e46dce7a9b949632af18ee74d97ffc3f2b41fe7f448b0";
  };

  nativeBuildInputs = [
    flex
    bison
  ];

  buildInputs = [
    dbus
    libnl
    libusb
  ];
  
  configureFlags = [
    "--with-pcap=linux"
    "--with-libnl"
    "--enable-ipv6"
    "--enable-shared"
    "--enable-usb"
    "--disable-bluetooth"  # TODO: I think this needs newer headers
    "--enable-canusb"
    "--enable-can"
    "--enable-dbus"
  ];

  preBuild = ''
    export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE -I$(echo "${libnl}"/include/*)"
  '';

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      pgpsigUrl = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprint = "1F16 6A57 42AB B9E0 249A  8D30 E089 DEF1 D9C1 5D0D";
      inherit (src) urls outputHash outputHashAlgo;
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
