{ stdenv
, cmake
, fetchurl
, ninja

, kerberos
, libsodium
, zlib
, openssl_1-0-2
}:

stdenv.mkDerivation rec {
  name = "libssh-0.7.5";

  src = fetchurl {
    url = "https://red.libssh.org/attachments/download/218/libssh-0.7.5.tar.xz";
    multihash = "QmeLAG99dVtcZLQTtnmCXbfqCdaPYei4Prx6w16ZUSmxVb";
    hashOutput = false;
    sha256 = "54e86dd5dc20e5367e58f3caab337ce37675f863f80df85b6b1614966a337095";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    kerberos
    libsodium
    openssl_1-0-2
    zlib
  ];

  postPatch = ''
    # Fix headers to use libsodium instead of NaCl
    sed -i 's,nacl/,sodium/,g' ./include/libssh/curve25519.h src/curve25519.c
  '';

  cmakeFlags = [
    "-DWITH_GSSAPI=ON"
    "-DWITH_ZLIB=ON"
    "-DWITH_SSH1=OFF"
    "-DWITH_SFTP=ON"
    "-DWITH_SERVER=ON"
    "-DWITH_STATIC_LIB=OFF"
    "-DWITH_DEBUG_CRYPTO=OFF"
    "-DWITH_DEBUG_CALLTRACE=OFF"
    "-DWITH_GCRYPT=OFF"
    "-DWITH_PCAP=ON"
    "-DWITH_INTERNAL_DOC=OFF"
    "-DWITH_TESTING=OFF"
    "-DWITH_CLIENT_TESTING=OFF"
    "-DWITH_BENCHMARKS=OFF"
    "-DWITH_EXAMPLES=OFF"
    "-DWITH_NACL=ON"
    "-DNACL_LIBRARY=${libsodium}/lib/libsodium.so"
    "-DNACL_INCLUDE_DIR=${libsodium}/include"
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpDecompress = true;
      pgpsigUrl = "https://red.libssh.org/attachments/download/217/libssh-0.7.5.tar.asc";
      pgpKeyFingerprint = "8DFF 53E1 8F2A BC8D 8F3C  9223 7EE0 FC4D CC01 4E3D";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    description = "SSH client library";
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
