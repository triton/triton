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
  version = "4.1.0";
in
stdenv.mkDerivation rec {
  name = "libtiff-${version}";

  src = fetchurl {
    url = "https://download.osgeo.org/libtiff/tiff-${version}.tar.gz";
    multihash = "QmRzaJStcaGEoN9Wu3fFzG7PcftDidP7M3vSVKi2EUrmmo";
    hashOutput = false;
    sha256 = "5d29f32517dadb6dbcd1255ea5bbc93a2b54b94fbf83653b4d65c7d6775b8634";
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
