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
  version = "2.9.10";

  tarballUrls = version: [
    "http://xmlsoft.org/sources/libxml2-${version}.tar.gz"
  ];
in
stdenv.mkDerivation rec {
  name = "libxml2-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    multihash = "QmPWcjgfiucBtkhxoWqJjHcKDXuj7QTmj5qnrCRfxgBJXj";
    hashOutput = false;
    sha256 = "aafee193ffb8fe0c82d4afef6ef91972cbaf5feea100edc2f262750611b4be1f";
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
      urls = tarballUrls "2.9.10";
      inherit (src) outputHashAlgo;
      outputHash = "aafee193ffb8fe0c82d4afef6ef91972cbaf5feea100edc2f262750611b4be1f";
      fullOpts = {
        pgpsigUrls = map (n: "${n}.asc") urls;
        pgpKeyFingerprint = "C744 15BA 7C9C 7F78 F02E  1DC3 4606 B8A5 DE95 BC1F";
      };
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
