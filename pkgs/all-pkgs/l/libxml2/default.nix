{ stdenv
, fetchTritonPatch
, fetchurl

, findXMLCatalogs
, icu
, readline
, xz
, zlib
}:

let
  version = "2.9.8";

  tarballUrls = version: [
    "http://xmlsoft.org/sources/libxml2-${version}.tar.gz"
  ];
in
stdenv.mkDerivation rec {
  name = "libxml2-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    multihash = "QmNzhnPYCnLukCSrycQNEkxJsghY9KP45cKeLqiKxxf6Ca";
    hashOutput = false;
    sha256 = "0b74e51595654f958148759cfef0993114ddccccbb6f31aee018f3558e8e2732";
  };

  buildInputs = [
    icu
    readline
    xz
    zlib
  ];

  propagatedBuildInputs = [
    findXMLCatalogs
  ];

  configureFlags = [
    "--with-icu=${icu}"
    "--with-readline=${readline}"
    "--with-zlib=${zlib}"
    "--with-lzma=${xz}"
  ];

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "2.9.8";
      pgpsigUrls = map (n: "${n}.asc") urls;
      pgpKeyFingerprint = "C744 15BA 7C9C 7F78 F02E  1DC3 4606 B8A5 DE95 BC1F";
      inherit (src) outputHashAlgo;
      outputHash = "0b74e51595654f958148759cfef0993114ddccccbb6f31aee018f3558e8e2732";
    };
  };

  meta = with stdenv.lib; {
    homepage = http://xmlsoft.org/;
    description = "An XML parsing library for C";
    license = licenses.mit;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
