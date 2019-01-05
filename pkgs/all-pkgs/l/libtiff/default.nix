{ stdenv
, fetchTritonPatch
, fetchurl

, jbigkit
, libjpeg
, xz
, zlib
, zstd
}:

let
  version = "4.0.10";
in
stdenv.mkDerivation rec {
  name = "libtiff-${version}";

  src = fetchurl {
    url = "https://download.osgeo.org/libtiff/tiff-${version}.tar.gz";
    multihash = "QmfUyXXCpjnQkoxD2qsZycKyFKD9S1nH1tP89dztgrFDaM";
    hashOutput = false;
    sha256 = "2c52d11ccaf767457db0c46795d9c7d1a8d8f76f68b0b800a3dfe45786b996e4";
  };

  buildInputs = [
    jbigkit
    libjpeg
    xz
    zlib
    zstd
  ];

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
      fullOpts = {
        pgpsigUrls = map (n: "${n}.sig") src.urls;
        pgpKeyFingerprint = "EBDF DB21 B020 EE8F D151  A88D E301 047D E119 8975";
      };
    };
  };

  meta = with stdenv.lib; {
    description = "Library and utilities for working with the TIFF image file format";
    homepage = http://www.remotesensing.org/libtiff/;
    license = licenses.libtiff;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
