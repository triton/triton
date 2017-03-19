{ stdenv
, fetchurl

, libmnl
}:

stdenv.mkDerivation rec {
  name = "ipset-6.32";

  src = fetchurl {
    url = "http://ipset.netfilter.org/${name}.tar.bz2";
    multihash = "QmWRJQkHqnbkzCYVC1REErbzod8vhrhDcwystxS959MDKT";
    hashOutput = false;
    sha256 = "d9cbb49a4ae9e32d7808a604f1a37f359f9fc9064c210c4c5f35d629d49fb9fe";
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
