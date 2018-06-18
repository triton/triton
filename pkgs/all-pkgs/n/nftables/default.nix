{ stdenv
, bison
, docbook2x
, docbook_xml_dtd_45
, fetchurl
, flex
, lib

, gmp
, jansson
, iptables
, libmnl
, libnftnl
, readline
}:

stdenv.mkDerivation rec {
  name = "nftables-0.9.0";

  src = fetchurl {
    url = "http://netfilter.org/projects/nftables/files/${name}.tar.bz2";
    multihash = "QmVRkBjAnaDLBh56CGRGDEwdoaryZC9sajqXrjRyjH4X2A";
    hashOutput = false;
    sha256 = "ad8181b5fcb9ca572f444bed54018749588522ee97e4c21922648bb78d7e7e91";
  };

  nativeBuildInputs = [
    bison
    docbook2x
    docbook_xml_dtd_45
    flex
  ];

  buildInputs = [
    gmp
    jansson
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
    "--with-json"
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
