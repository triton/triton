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
  version = "2.9.9";

  tarballUrls = version: [
    "http://xmlsoft.org/sources/libxml2-${version}.tar.gz"
  ];
in
stdenv.mkDerivation rec {
  name = "libxml2-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    multihash = "QmZW6enUX5jA8JNCK72oQnCiaG4FEPuCHoC84yg12WyDqA";
    hashOutput = false;
    sha256 = "94fb70890143e3c6549f265cee93ec064c80a84c42ad0f23e85ee1fd6540a871";
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
      urls = tarballUrls "2.9.9";
      inherit (src) outputHashAlgo;
      outputHash = "94fb70890143e3c6549f265cee93ec064c80a84c42ad0f23e85ee1fd6540a871";
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
