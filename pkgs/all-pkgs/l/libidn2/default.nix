{ stdenv
, fetchurl
}:

let
  version = "2.1.1";

  tarballUrls = version: [
    "mirror://gnu/libidn/libidn2-${version}.tar.gz"
  ];
in
stdenv.mkDerivation rec {
  name = "libidn2-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "95416080329298a13269e13175041b530cec3d98b54cafae9424b8dfd22078b1";
  };

  configureFlags = [
    "--disable-doc"
  ];

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "2.1.1";
      inherit (src) outputHashAlgo;
      outputHash = "95416080329298a13269e13175041b530cec3d98b54cafae9424b8dfd22078b1";
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
