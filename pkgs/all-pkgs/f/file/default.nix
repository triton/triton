{ stdenv
, fetchurl

, libseccomp
, zlib
}:

stdenv.mkDerivation rec {
  name = "file-5.37";

  src = fetchurl {
    url = "ftp://ftp.astron.com/pub/file/${name}.tar.gz";
    multihash = "QmTZr1Sy7GXgeFDNmUDdDmFjgKpXxzKECLkxZibifcWYXH";
    hashOutput = false;
    sha256 = "e9c13967f7dd339a3c241b7710ba093560b9a33013491318e88e6b8b57bae07f";
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
