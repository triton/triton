{ stdenv
, bison
, fetchurl
, flex

, dbus
, libnl
, rdma-core
}:

stdenv.mkDerivation rec {
  name = "libpcap-1.9.0";

  src = fetchurl {
    url = "http://www.tcpdump.org/release/${name}.tar.gz";
    multihash = "QmT79aKdU6rvxhDRt9HXRCahVrsu9y7d9dLWfqS3ooas8H";
    hashOutput = false;
    sha256 = "2edb88808e5913fdaa8e9c1fcaf272e19b2485338742b5074b9fe44d68f37019";
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
