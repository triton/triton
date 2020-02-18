{ stdenv
, fetchurl

, libseccomp
, zlib
}:

stdenv.mkDerivation rec {
  name = "file-5.38";

  src = fetchurl {
    url = "ftp://ftp.astron.com/pub/file/${name}.tar.gz";
    multihash = "QmTKjyWXdw9DKeYVQMsJ7NMsgePqiZjp4q7RbVAz5SrC9Y";
    hashOutput = false;
    sha256 = "593c2ffc2ab349c5aea0f55fedfe4d681737b6b62376a9b3ad1e77b2cc19fa34";
  };

  buildInputs = [
    libseccomp
    zlib
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
      fullOpts = {
        pgpsigUrls = map (n: "${n}.asc") src.urls;
        pgpKeyFingerprint = "BE04 995B A8F9 0ED0 C0C1  76C4 7111 2AB1 6CB3 3B3A";
      };
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
