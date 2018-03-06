{ stdenv
, fetchurl
, lib

, libmnl
}:

stdenv.mkDerivation rec {
  name = "ipset-6.36";

  src = fetchurl {
    url = "http://ipset.netfilter.org/${name}.tar.bz2";
    multihash = "QmQmXyc5cfKParMzketuNYrxJWzcYU5rRZFdJEBLTJd29s";
    hashOutput = false;
    sha256 = "22224a90dc6c7d97b7a7addedd0740c3841e3d9a7ff8c8d2123bae0c3620d30d";
  };

  buildInputs = [
    libmnl
  ];

  configureFlags = [
    "--with-kmod=no"
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      md5Urls = map (n: "${n}.md5sum.txt") src.urls;
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with lib; {
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
