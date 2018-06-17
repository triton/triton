{ stdenv
, fetchurl

, openssl
}:

let
  tarballUrls = version: [
    "https://libbsd.freedesktop.org/releases/libbsd-${version}.tar.xz"
  ];

  version = "0.9.1";
in
stdenv.mkDerivation rec {
  name = "libbsd-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    multihash = "QmVK1Z5H2Gx8xpKMbtpuLzfU43mYH5Zguq5divoYwc5qpe";
    hashOutput = false;
    sha256 = "56d835742327d69faccd16955a60b6dcf30684a8da518c4eca0ac713b9e0a7a4";
  };

  buildInputs = [
    openssl
  ];

  postPatch = ''
    sed \
      -e "s,/usr,$out,g" \
      -e 's,{exec_prefix},{prefix},g' \
      -i Makefile.in
  '';

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "0.9.1";
      pgpsigUrls = map (n: "${n}.asc") urls;
      pgpKeyFingerprint = "4F3E 74F4 3605 0C10 F569  6574 B972 BF3E A4AE 57A3";
      inherit (src) outputHashAlgo;
      outputHash = "56d835742327d69faccd16955a60b6dcf30684a8da518c4eca0ac713b9e0a7a4";
    };
  };

  meta = with stdenv.lib; {
    description = "Common functions found on BSD systems";
    homepage = http://libbsd.freedesktop.org/;
    license = licenses.bsd3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
