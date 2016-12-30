{ stdenv
, bison
, fetchurl
, flex

, gmp
, libmnl
, libnftnl
, readline
}:

stdenv.mkDerivation rec {
  name = "nftables-0.7";

  src = fetchurl {
    url = "http://netfilter.org/projects/nftables/files/${name}.tar.bz2";
    hashOutput = false;
    multihash = "QmPaVkUfFmLDUCtiGHnwRUVhY9b7zbhWuypXLccUMNKEH5";
    sha256 = "fe639239d801ce5890397f6f4391c58a934bfc27d8b7d5ef922692de5ec4ed43";
  };

  nativeBuildInputs = [
    bison
    flex
  ];

  buildInputs = [
    gmp
    libmnl
    libnftnl
    readline
  ];

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--without-mini-gmp"
    "--with-cli"
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
