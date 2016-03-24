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
  name = "nftables-0.5";

  src = fetchurl {
    url = "http://netfilter.org/projects/nftables/files/${name}.tar.bz2";
    sha1Confirm  = "34cfe1daa33d7fd7087dd63199f64854dfb54064";
    sha256 = "1mhaw7ys7ma5786xyfccgar389jsj2zp7qmvghsgr96q6grxzdhz";
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
