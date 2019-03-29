{ stdenv
, fetchurl

, openssl
, zlib
}:

stdenv.mkDerivation rec {
  name = "libssh2-1.8.2";

  src = fetchurl {
    url = "https://www.libssh2.org/download/${name}.tar.gz";
    multihash = "QmY53BrpWEkoySU9p9qVWtyj7ENQMR8hD4ZLKNGzGc8CEx";
    hashOutput = false;
    sha256 = "088307d9f6b6c4b8c13f34602e8ff65d21c2dc4d55284dfe15d502c4ee190d67";
  };

  buildInputs = [
    openssl
    zlib
  ];

  configureFlags = [
    "--disable-examples-build"
    "--with-openssl"
    "--with-libz"
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
