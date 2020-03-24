{ stdenv
, fetchurl
}:

let
  tarballUrls = version: [
    "https://c-ares.haxx.se/download/c-ares-${version}.tar.gz"
  ];

  version = "1.16.0";
in
stdenv.mkDerivation rec {
  name = "c-ares-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    multihash = "Qmd1mnDfQxcwU8VSRUgHYDUpiVtjhvFrLTpHsnitU79nFR";
    hashOutput = false;
    sha256 = "de058ad7c128156e2db6dc98b8a359924d6f210a1b99dd36ba15c8f839a83a89";
  };

  passthru = {
    srcVerification = fetchurl rec {
      inherit (src) outputHashAlgo;
      urls = tarballUrls "1.16.0";
      outputHash = "de058ad7c128156e2db6dc98b8a359924d6f210a1b99dd36ba15c8f839a83a89";
      failEarly = true;
      fullOpts = {
        pgpsigUrls = map (n: "${n}.asc") urls;
        pgpKeyFingerprint = "27ED EAF2 2F3A BCEB 50DB  9A12 5CC9 08FD B71E 12C2";
      };
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
