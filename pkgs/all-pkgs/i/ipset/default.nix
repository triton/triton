{ stdenv
, fetchurl

, libmnl
}:

stdenv.mkDerivation rec {
  name = "ipset-6.35";

  src = fetchurl {
    url = "http://ipset.netfilter.org/${name}.tar.bz2";
    multihash = "QmRfMyPAogoVJxds8F8i28nLshwCxyzYytVsVHbvQ9iA6L";
    hashOutput = false;
    sha256 = "37071013e1f92e0ca2f5deac86e657db87290fe651f64f44ce662f3aa40bf4dc";
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
