{ stdenv
, fetchurl

, libmnl
}:

stdenv.mkDerivation rec {
  name = "ipset-6.34";

  src = fetchurl {
    url = "http://ipset.netfilter.org/${name}.tar.bz2";
    multihash = "QmPe2cF638g4jG1oSt3x4spUqKZDbF4PZSCofQEj3T8Sjm";
    hashOutput = false;
    sha256 = "d70e831b670b7aa25dde81fd994d3a7ce0c0e801559a557105576df66cd8d680";
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
