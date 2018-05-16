{ stdenv
, fetchurl
}:

let
  tarballUrls = version: [
    "https://c-ares.haxx.se/download/c-ares-${version}.tar.gz"
  ];

  version = "1.14.0";
in
stdenv.mkDerivation rec {
  name = "c-ares-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    multihash = "QmRtEZDegbvV7FBwQv9tADmkJRwEGXWcKbU1obQn1KXTSn";
    hashOutput = false;
    sha256 = "45d3c1fd29263ceec2afc8ff9cd06d5f8f889636eb4e80ce3cc7f0eaf7aadc6e";
  };

  passthru = {
    srcVerification = fetchurl rec {
      inherit (src) outputHashAlgo;
      urls = tarballUrls "1.14.0";
      pgpsigUrls = map (n: "${n}.asc") urls;
      outputHash = "45d3c1fd29263ceec2afc8ff9cd06d5f8f889636eb4e80ce3cc7f0eaf7aadc6e";
      pgpKeyFingerprint = "27ED EAF2 2F3A BCEB 50DB  9A12 5CC9 08FD B71E 12C2";
      failEarly = true;
    };
  };

  meta = with stdenv.lib; {
    description = "A C library for asynchronous DNS requests";
    homepage = http://c-ares.haxx.se;
    license = licenses.mit;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
