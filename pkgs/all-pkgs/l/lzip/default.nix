{ stdenv
, fetchurl
, texinfo
}:

stdenv.mkDerivation rec {
  name = "lzip-1.19";

  src = fetchurl {
    url = "mirror://savannah/lzip/${name}.tar.gz";
    hashOutput = false;
    sha256 = "ffadc4f56be1bc0d3ae155ec4527bd003133bdc703a753b2cc683f610e646ba9";
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
