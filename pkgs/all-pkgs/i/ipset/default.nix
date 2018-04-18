{ stdenv
, fetchurl
, lib

, libmnl
}:

stdenv.mkDerivation rec {
  name = "ipset-6.38";

  src = fetchurl {
    url = "http://ipset.netfilter.org/${name}.tar.bz2";
    multihash = "QmYRzzDYxdx7CLuCiFoUFKcLAmUtpDgJeeDVcxCNNRtEfj";
    hashOutput = false;
    sha256 = "ceef625ba31fe0aaa422926c7231a819de0b07644c02c17ebdd3022a29e3e244";
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
