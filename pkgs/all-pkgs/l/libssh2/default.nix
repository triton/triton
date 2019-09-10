{ stdenv
, fetchurl

, openssl
, zlib
}:

stdenv.mkDerivation rec {
  name = "libssh2-1.9.0";

  src = fetchurl {
    url = "https://www.libssh2.org/download/${name}.tar.gz";
    multihash = "QmT68tepb4apvruR8So3GA6fSAtxKZ5pQHPZrdXgV8kpBV";
    hashOutput = false;
    sha256 = "d5fb8bd563305fd1074dda90bd053fb2d29fc4bce048d182f96eaa466dfadafd";
  };

  buildInputs = [
    openssl
    zlib
  ];

  configureFlags = [
    "--disable-examples-build"
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
        pgpKeyFingerprint = "27ED EAF2 2F3A BCEB 50DB  9A12 5CC9 08FD B71E 12C2";
      };
    };
  };

  meta = with stdenv.lib; {
    description = "A client-side C library implementing the SSH2 protocol";
    homepage = http://www.libssh2.org;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
