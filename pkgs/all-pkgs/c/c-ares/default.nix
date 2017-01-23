{ stdenv
, fetchurl
}:

let
  tarballUrls = version: [
    "https://c-ares.haxx.se/download/c-ares-${version}.tar.gz"
  ];

  version = "1.12.0";
in
stdenv.mkDerivation rec {
  name = "c-ares-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    multihash = "QmVooF91kBXG9c2drfaHZXruSSXNfGBSb1bNceWCPvhHZ6";
    sha256 = "8692f9403cdcdf936130e045c84021665118ee9bfea905d1a76f04d4e6f365fb";
  };

  passthru = {
    srcVerification = fetchurl rec {
      inherit (src) outputHashAlgo;
      urls = tarballUrls "1.12.0";
      pgpsigUrls = map (n: "${n}.asc") urls;
      outputHash = "8692f9403cdcdf936130e045c84021665118ee9bfea905d1a76f04d4e6f365fb";
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
