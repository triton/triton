{ stdenv
, fetchTritonPatch
, fetchurl

, findXMLCatalogs
, libxml2
}:

let
  tarballUrls = version: [
    "http://xmlsoft.org/sources/libxslt-${version}.tar.gz"
  ];

  version = "1.1.30";
in
stdenv.mkDerivation rec {
  name = "libxslt-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    multihash = "QmPkxXTGmrFPCvGZyHqGRvBJz4B7rRNiVmVLinf6Kom2NP";
    hashOutput = false;
    sha256 = "ba65236116de8326d83378b2bd929879fa185195bc530b9d1aba72107910b6b3";
  };

  buildInputs = [
    libxml2
  ];

  propagatedBuildInputs = [
    findXMLCatalogs
  ];

  patches = [
    (fetchTritonPatch {
      rev = "6c24b4d6845e8d1be84a9e0abe36b601d395ff09";
      file = "l/libxslt/CVE-2016-4738.patch";
      sha256 = "334ab9a931e09fd310d6e75a0e0b488cee12280d6384c8b884c2fd3a154b18ec";
    })
  ];

  configureFlags = [
    "--with-libxml-prefix=${libxml2}"
    "--without-python"
    "--with-crypto"
    "--without-debug"
    "--without-mem-debug"
    "--without-debugger"
  ];

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "1.1.30";
      pgpsigUrls = map (n: "${n}.asc") urls;
      pgpKeyFingerprint = "C744 15BA 7C9C 7F78 F02E  1DC3 4606 B8A5 DE95 BC1F";
      inherit (src) outputHashAlgo;
      outputHash = "ba65236116de8326d83378b2bd929879fa185195bc530b9d1aba72107910b6b3";
    };
  };

  meta = with stdenv.lib; {
    homepage = http://xmlsoft.org/XSLT/;
    description = "A C library and tools to do XSL transformations";
    license = licenses.bsd3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
