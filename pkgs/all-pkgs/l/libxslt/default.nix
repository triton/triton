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

  version = "1.1.34";
in
stdenv.mkDerivation rec {
  name = "libxslt-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    multihash = "QmUpf2GX77PjxXQkkhsSuozWPwGJZC7cmjZ9x9Cf9pJEGF";
    hashOutput = false;
    sha256 = "98b1bd46d6792925ad2dfe9a87452ea2adebf69dcb9919ffd55bf926a7f93f7f";
  };

  buildInputs = [
    libxml2
  ];

  propagatedBuildInputs = [
    findXMLCatalogs
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
      urls = tarballUrls "1.1.34";
      inherit (src) outputHashAlgo;
      outputHash = "98b1bd46d6792925ad2dfe9a87452ea2adebf69dcb9919ffd55bf926a7f93f7f";
      fullOpts = {
        pgpsigUrls = map (n: "${n}.asc") urls;
        pgpKeyFingerprint = "C744 15BA 7C9C 7F78 F02E  1DC3 4606 B8A5 DE95 BC1F";
      };
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
