{ stdenv
, fetchurl
, lib

, libmnl
}:

stdenv.mkDerivation rec {
  name = "ipset-7.6";

  src = fetchurl {
    url = "http://ipset.netfilter.org/${name}.tar.bz2";
    multihash = "QmPsHr9PXKdLm5T49x3WBq23pkpmqpP8bJML9ppojebrAM";
    hashOutput = false;
    sha256 = "0e7d44caa9c153d96a9b5f12644fbe35a632537a5a7f653792b72e53d9d5c2db";
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
