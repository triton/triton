{ stdenv
, bison
, docbook2x
, fetchurl
, flex

, gmp
, iptables
, libmnl
, libnftnl
, readline
}:

stdenv.mkDerivation rec {
  name = "nftables-0.8";

  src = fetchurl {
    url = "http://netfilter.org/projects/nftables/files/${name}.tar.bz2";
    multihash = "QmP72Q17QGWm9K14mQgXtJ3NgCRHWrLqrTqLAs5MENfuwh";
    hashOutput = false;
    sha256 = "3f5b88e7b163bb46aa39e89419686b98f9316606a05865c3856dc68e414f389a";
  };

  nativeBuildInputs = [
    bison
    docbook2x
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
