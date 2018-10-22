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
  version = "${major}.4";
in
stdenv.mkDerivation rec {
  name = "libssh-${version}";

  src = fetchurl {
    url = "https://www.libssh.org/files/${major}/${name}.tar.xz";
    multihash = "QmPnMTY74CGD99YrjY72QygrZUv1fk7mNP4YnR6eFxrqo4";
    hashOutput = false;
    sha256 = "6bb07713021a8586ba2120b2c36c468dc9ac8096d043f9b1726639aa4275b81b";
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
