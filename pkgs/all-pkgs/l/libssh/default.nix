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
  version = "${major}.7";
in
stdenv.mkDerivation rec {
  name = "libssh-${version}";

  src = fetchurl {
    url = "https://www.libssh.org/files/${major}/${name}.tar.xz";
    multihash = "QmTP4YPcJtS3bcnN3BEcZgMfU9XektrxZrcfXQ5948rcQq";
    hashOutput = false;
    sha256 = "43304ca22f0ba0b654e14b574a39816bc70212fdea5858a6637cc26cade3d592";
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
