{ stdenv
, fetchurl

, openssl
, zlib
}:

stdenv.mkDerivation rec {
  name = "libssh2-1.8.0";

  src = fetchurl {
    url = "https://www.libssh2.org/download/${name}.tar.gz";
    multihash = "QmY6PpE6gRK4vY5i277niCrMvev4pxqpxoqBNbXwXkUrzH";
    hashOutput = false;
    sha256 = "39f34e2f6835f4b992cafe8625073a88e5a28ba78f83e8099610a7b3af4676d4";
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
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      pgpKeyFingerprint = "27ED EAF2 2F3A BCEB 50DB  9A12 5CC9 08FD B71E 12C2";
      inherit (src) urls outputHash outputHashAlgo;
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
