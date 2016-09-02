{ stdenv
, fetchurl
, m4
}:

let
  version = "6.1.1";

  tarballUrls = version: [
    "mirror://gnu/gmp/gmp-${version}.tar.bz2"
    "ftp://ftp.gmplib.org/pub/gmp-${version}/gmp-${version}.tar.bz2"
  ];
in
stdenv.mkDerivation rec {
  name = "gmp-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "a8109865f2893f1373b0a8ed5ff7429de8db696fc451b1036bd7bdf95bbeffd6";
  };

  nativeBuildInputs = [
    m4
  ];

  configureFlags = [
    "--with-pic"
    "--enable-fat"
    "--enable-cxx"
  ];

  doCheck = true;

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "6.1.1";
      pgpsigUrls = map (n: "${n}.sig") urls;
      pgpKeyFingerprint = "343C 2FF0 FBEE 5EC2 EDBE  F399 F359 9FF8 28C6 7298";
      inherit (src) outputHashAlgo;
      outputHash = "a8109865f2893f1373b0a8ed5ff7429de8db696fc451b1036bd7bdf95bbeffd6";
    };
  };

  meta = with stdenv.lib; {
    homepage = "http://gmplib.org/";
    description = "GNU multiple precision arithmetic library";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
