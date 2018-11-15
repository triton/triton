{ stdenv
, fetchurl
, lib

, libmnl
}:

stdenv.mkDerivation rec {
  name = "ipset-7.0";

  src = fetchurl {
    url = "http://ipset.netfilter.org/${name}.tar.bz2";
    multihash = "QmYVhqBr4ZfNB67bg4neFL8trzmRuaC5cPhgtQdN5ufWS3";
    hashOutput = false;
    sha256 = "c6fa0f3b7d514e3edd0113ea02f82ab299e5467a4b7733dc31e127cdccc741af";
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
