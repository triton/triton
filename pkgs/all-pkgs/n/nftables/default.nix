{ stdenv
, bison
, docbook2x
, docbook_xml_dtd_45
, fetchurl
, flex

, gmp
, iptables
, libmnl
, libnftnl
, readline
}:

stdenv.mkDerivation rec {
  name = "nftables-0.8.2";

  src = fetchurl {
    url = "http://netfilter.org/projects/nftables/files/${name}.tar.bz2";
    multihash = "Qmf8DA2sbUY6J6WXAfaauaj1TSqj4DdrrBm9yku9D5bj1K";
    hashOutput = false;
    sha256 = "675f0aaf88f11e7eacef63dc89cb65d207d9e09c3ea6d518f0ebbb013f0767ec";
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

  meta = with stdenv.lib; {
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
