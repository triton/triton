{ stdenv
, bison
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
  name = "nftables-0.9.3";

  src = fetchurl {
    url = "http://netfilter.org/projects/nftables/files/${name}.tar.bz2";
    multihash = "QmVqAMHSdqYWNw5skUguzVmhQ5awp44kbz4hBK43P2Z9SW";
    hashOutput = false;
    sha256 = "956b915ce2a7aeaff123e49006be7a0690a0964e96c062703181a36e2e5edb78";
  };

  nativeBuildInputs = [
    bison
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
    "--disable-man-doc"  # No asciidoc support
    "--with-xtables"
    "--with-json"
  ];

  preInstall = ''
    installFlagsArray+=("sysconfdir=$out/etc")
  '';

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
      fullOpts = {
        pgpsigUrl = map (n: "${n}.sig") src.urls;
        pgpKeyFingerprint = "C09D B206 3F1D 7034 BA61  52AD AB46 55A1 26D2 92E4";
      };
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
