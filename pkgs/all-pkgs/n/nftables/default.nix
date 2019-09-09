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
  name = "nftables-0.9.2";

  src = fetchurl {
    url = "http://netfilter.org/projects/nftables/files/${name}.tar.bz2";
    multihash = "Qmd7hkQ4WJJiUBLePJYR3rAMC7puy4fXT4zFecyx9d9HrZ";
    hashOutput = false;
    sha256 = "5cb66180143e6bfc774f4eb316206d40ac1cb6df269a90882404cbf7165513f5";
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
