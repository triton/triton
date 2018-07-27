{ stdenv
, fetchurl

, libseccomp
, zlib
}:

stdenv.mkDerivation rec {
  name = "file-5.34";

  src = fetchurl {
    url = "ftp://ftp.astron.com/pub/file/${name}.tar.gz";
    multihash = "QmZyLU7tkfswRTQL4CeYPYxWBzrSdkTdKcZs2W2NeD45Yp";
    hashOutput = false;
    sha256 = "f15a50dbbfa83fec0bd1161e8e191b092ec832720e30cd14536e044ac623b20a";
  };

  buildInputs = [
    libseccomp
    zlib
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      pgpKeyFingerprint = "BE04 995B A8F9 0ED0 C0C1  76C4 7111 2AB1 6CB3 3B3A";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    description = "A program that shows the type of files";
    homepage = "http://darwinsys.com/file";
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
