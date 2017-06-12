{ stdenv
, fetchurl
, lzip
}:

let
  version = "2.0.2";

  tarballUrls = version: [
    "mirror://gnu/libidn/libidn2-${version}.tar.lz"
  ];
in
stdenv.mkDerivation rec {
  name = "libidn2-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "5886c65ada48eb7bb0c03533ecad7f13048d998d2e1903428844aa001a920a5f";
  };
  
  nativeBuildInputs = [
    lzip
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      urls = tarballUrls "2.0.2";
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprint = "1CB2 7DBC 9861 4B2D 5841  646D 0830 2DB6 A267 0428";
      inherit (src) outputHashAlgo;
      outputHash = "5886c65ada48eb7bb0c03533ecad7f13048d998d2e1903428844aa001a920a5f";
    };
  };

  meta = with stdenv.lib; {
    homepage = http://www.gnu.org/software/libidn/;
    description = "Library for internationalized domain names";
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
