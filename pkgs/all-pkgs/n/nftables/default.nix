{ stdenv
, bison
, docbook2x
, docbook_xml_dtd_45
, fetchurl
, flex
, lib

, gmp
, iptables
, libmnl
, libnftnl
, readline
}:

stdenv.mkDerivation rec {
  name = "nftables-0.8.3";

  src = fetchurl {
    url = "http://netfilter.org/projects/nftables/files/${name}.tar.bz2";
    multihash = "QmX4Q9t5gfPRzU3q97q4s6Kfdjnm4byxE1b5iVnqWmnsoF";
    hashOutput = false;
    sha256 = "d16be1f5db88e95d29fc0b0e4df88acd079f3ee8e2b872ec7673f9a0d5d95e38";
  };

  nativeBuildInputs = [
    bison
    docbook2x
    docbook_xml_dtd_45
    flex
  ];

  buildInputs = [
    gmp
    iptables
    libmnl
    libnftnl
    readline
  ];

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--without-mini-gmp"
    "--with-cli"
    "--with-xtables"
  ];

  preInstall = ''
    installFlagsArray+=("sysconfdir=$out/etc")
  '';

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrl = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprint = "C09D B206 3F1D 7034 BA61  52AD AB46 55A1 26D2 92E4";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with lib; {
    description = "the project that aims to replace the existing {ip,ip6,arp,eb}tables framework";
    homepage = http://netfilter.org/projects/nftables;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
