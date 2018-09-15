{ stdenv
, cmake
, fetchurl
, ninja

, kerberos
, libsodium
, zlib
, openssl
}:

let
  major = "0.8";
  version = "${major}.2";
in
stdenv.mkDerivation rec {
  name = "libssh-${version}";

  src = fetchurl {
    url = "https://www.libssh.org/files/${major}/${name}.tar.xz";
    multihash = "QmQd4Ptkp1xpGwMA5yQtvUPcmG1vjh8TZWqLnYTdNpUnx2";
    hashOutput = false;
    sha256 = "8d1290f0fac4f8a75a9001dd404a8a093daba4e86c90c45ecf77d62f14c7b8a5";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    kerberos
    libsodium
    openssl
    zlib
  ];

  postPatch = ''
    # We don't need python for our build
    grep -q 'find_package(PythonInterp REQUIRED)' cmake/Modules/FindABIMap.cmake
    sed -i '/find_package(PythonInterp REQUIRED)/d' cmake/Modules/FindABIMap.cmake
  '';

  cmakeFlags = [
    "-DWITH_DEBUG_CALLTRACE=OFF"
    "-DWITH_EXAMPLES=OFF"
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
      fullOpts = {
        pgpDecompress = true;
        pgpsigUrls = map (n: "${n}.asc") src.urls;
        pgpKeyFingerprint = "8DFF 53E1 8F2A BC8D 8F3C  9223 7EE0 FC4D CC01 4E3D";
      };
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
