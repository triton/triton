{ stdenv
, fetchurl
}:

let
  tarballUrls = version: [
    "mirror://savannah/lzip/lzip-${version}.tar.gz"
  ];

  version = "1.20";
in
stdenv.mkDerivation rec {
  name = "lzip-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "c93b81a5a7788ef5812423d311345ba5d3bd4f5ebf1f693911e3a13553c1290c";
  };

  configureFlags = [
    "CPPFLAGS=-DNDEBUG"
    "CFLAGS=-O3"
    "CXXFLAGS=-O3"
  ];

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "1.20";
      pgpsigUrls = map (n: "${n}.sig") urls;
      pgpKeyFingerprint = "1D41 C14B 272A 2219 A739  FA4F 8FE9 9503 132D 7742";
      inherit (src) outputHashAlgo;
      outputHash = "c93b81a5a7788ef5812423d311345ba5d3bd4f5ebf1f693911e3a13553c1290c";
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
