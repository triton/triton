{ stdenv
, fetchurl
, lib
}:

let
  inherit (lib)
    concatStringsSep
    splitString;

  version = "2.0.1";
  rel = "REL_" + concatStringsSep "_" (splitString "." version);
in
stdenv.mkDerivation rec {
  name = "log4cplus-${version}";

  src = fetchurl {
    urls = [
      "mirror://sourceforge/log4cplus/log4cplus-stable/${version}/${name}.tar.xz"
      "https://github.com/log4cplus/log4cplus/releases/download/${rel}/${name}.tar.xz"
    ];
    hashOutput = false;
    sha256 = "813580059fd91260376e411b3e09c740aa86dedc5f6a0bd975b9b39d5c4370e6";
  };

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprint = "E406 292F 7D08 BBB0 0846  1314 04B8 9D51 DFE5 A215";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with lib; {
    homepage = "http://log4cplus.sourceforge.net/";
    description = "a port the log4j library from Java to C++";
    license = licenses.asl20;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
