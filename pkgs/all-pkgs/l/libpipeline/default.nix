{ stdenv
, fetchurl
}:
 
stdenv.mkDerivation rec {
  name = "libpipeline-1.5.0";
  
  src = fetchurl {
    url = "mirror://savannah/libpipeline/${name}.tar.gz";
    hashOutput = false;
    sha256 = "0d72e12e4f2afff67fd7b9df0a24d7ba42b5a7c9211ac5b3dcccc5cd8b286f2b";
  };

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprint = "AC0A 4FF1 2611 B6FC CF01  C111 3935 87D9 7D86 500B";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    homepage = "http://libpipeline.nongnu.org";
    description = "C library for manipulating pipelines of subprocesses in a flexible and convenient way";
    license = licenses.gpl3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
