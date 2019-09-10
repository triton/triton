{ stdenv
, fetchurl
, lib
}:

let
  tarballUrls = version: [
    "mirror://sourceforge/expat/expat/${version}/expat-${version}.tar.bz2"
  ];

  version = "2.2.7";
in
stdenv.mkDerivation rec {
  name = "expat-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "cbc9102f4a31a8dafd42d642e9a3aa31e79a0aedaa1f6efd2795ebc83174ec18";
  };

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      inherit (src)
        outputHashAlgo;
      urls = tarballUrls "2.2.7";
      fullOpts = {
        pgpsigUrls = map (n: "${n}.asc") urls;
        pgpKeyFingerprint = "3D7E 959D 89FA CFEE 3837  1921 B00B C66A 401A 1600";
      };
      outputHash = "cbc9102f4a31a8dafd42d642e9a3aa31e79a0aedaa1f6efd2795ebc83174ec18";
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
