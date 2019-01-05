{ stdenv
, fetchurl
}:

let
  version = "2.1.0";

  tarballUrls = version: [
    "mirror://gnu/libidn/libidn2-${version}.tar.gz"
  ];
in
stdenv.mkDerivation rec {
  name = "libidn2-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "032398dbaa9537af43f51a8d94e967e3718848547b1b2a4eb3138b20cad11d32";
  };

  configureFlags = [
    "--disable-doc"
  ];

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "2.1.0";
      inherit (src) outputHashAlgo;
      outputHash = "032398dbaa9537af43f51a8d94e967e3718848547b1b2a4eb3138b20cad11d32";
      fullOpts = {
        pgpsigUrls = map (n: "${n}.sig") urls;
        pgpKeyFingerprint = "1CB2 7DBC 9861 4B2D 5841  646D 0830 2DB6 A267 0428";
      };
    };
  };

  allowedReferences = [
    "out"
  ] ++ stdenv.cc.runtimeLibcLibs;

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
