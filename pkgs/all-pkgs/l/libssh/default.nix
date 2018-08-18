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
  version = "${major}.1";
in
stdenv.mkDerivation rec {
  name = "libssh-${version}";

  src = fetchurl {
    url = "https://www.libssh.org/files/${major}/${name}.tar.xz";
    multihash = "Qmc1sQATgtmjEjCRjpPMw8C23FF2nqGAfmqtU6xUgSz8aM";
    hashOutput = false;
    sha256 = "d17f1267b4a5e46c0fbe66d39a3e702b8cefe788928f2eb6e339a18bb00b1924";
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
      pgpDecompress = true;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
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
