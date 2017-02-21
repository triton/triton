{ stdenv
, fetchurl

, libmnl
}:

stdenv.mkDerivation rec {
  name = "ipset-6.31";

  src = fetchurl {
    url = "http://ipset.netfilter.org/${name}.tar.bz2";
    md5Confirm = "231790be940438287438df1f33857376";
    multihash = "QmbA5gjRv93Z9yQ4hr9CN7zxYG5FTbkqFViRrfXtaGQr1a";
    sha256 = "498e411cc1d134201a31a56def6c0936c642958c2d4b4ce7d9955240047a45fe";
  };

  buildInputs = [
    libmnl
  ];

  configureFlags = [
    "--with-kmod=no"
  ];

  meta = with stdenv.lib; {
    homepage = http://ipset.netfilter.org/;
    description = "Administration tool for IP sets";
    license = licenses.gpl2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
