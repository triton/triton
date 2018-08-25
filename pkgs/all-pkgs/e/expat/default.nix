{ stdenv
, fetchurl
, lib

, libbsd
}:

let
  tarballUrls = version: [
    "mirror://sourceforge/expat/expat/${version}/expat-${version}.tar.bz2"
  ];

  version = "2.2.6";
in
stdenv.mkDerivation rec {
  name = "expat-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "17b43c2716d521369f82fc2dc70f359860e90fa440bea65b3b85f0b246ea81f2";
  };

  configureFlags = [
    "--with-libbsd"
  ];

  buildInputs = [
    libbsd
  ];

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      inherit (src)
        outputHashAlgo;
      urls = tarballUrls "2.2.6";
      fullOpts = {
        pgpsigUrls = map (n: "${n}.asc") urls;
        pgpKeyFingerprint = "3D7E 959D 89FA CFEE 3837  1921 B00B C66A 401A 1600";
      };
      outputHash = "17b43c2716d521369f82fc2dc70f359860e90fa440bea65b3b85f0b246ea81f2";
    };
  };

  meta = with lib; {
    description = "A stream-oriented XML parser library written in C";
    homepage = http://www.libexpat.org/;
    license = licenses.mit;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
