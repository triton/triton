{ stdenv
, fetchurl
, texinfo
}:

stdenv.mkDerivation rec {
  name = "lzip-1.17";

  src = fetchurl {
    url = "mirror://savannah/lzip/${name}.tar.gz";
    allowHashOutput = false;
    sha256 = "9443855e0a33131233b22cdb6c62c9313a483f16cc7415efe88d4a494cea0352";
  };

  nativeBuildInputs = [
    texinfo
  ];

  configureFlags = [
    "CPPFLAGS=-DNDEBUG"
    "CFLAGS=-O3"
    "CXXFLAGS=-O3"
  ];

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprint = "1D41 C14B 272A 2219 A739  FA4F 8FE9 9503 132D 7742";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    homepage = "http://www.nongnu.org/lzip/lzip.html";
    description = "a lossless data compressor based on the LZMA algorithm";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
