{ stdenv
, fetchurl
, lib

, libmnl
}:

stdenv.mkDerivation rec {
  name = "ipset-7.1";

  src = fetchurl {
    url = "http://ipset.netfilter.org/${name}.tar.bz2";
    multihash = "QmRUBChtoMATH6KAgbzHf58fXwGoWy3XsBr3pvLgZNcWLn";
    hashOutput = false;
    sha256 = "7b5eb3b93205c20cdc39e3fc8b6e5f7bb214bf79a7c0c00729dd4a31ce16adc4";
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
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
      fullOpts = {
        md5Urls = map (n: "${n}.md5sum.txt") src.urls;
      };
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
