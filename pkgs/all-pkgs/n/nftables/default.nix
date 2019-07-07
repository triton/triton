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
  name = "nftables-0.9.1";

  src = fetchurl {
    url = "http://netfilter.org/projects/nftables/files/${name}.tar.bz2";
    multihash = "QmYVNBforqq4SEdMr2xM2DvT6WkRSEDYDxwyMWYT9XwsM8";
    hashOutput = false;
    sha256 = "ead3bb68ed540bfbb87a96f2b69c3d65ab0c2a0c3f6e739a395c09377d1b4fce";
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
