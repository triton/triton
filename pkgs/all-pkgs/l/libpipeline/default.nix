{ stdenv
, fetchurl
}:
 
stdenv.mkDerivation rec {
  name = "libpipeline-1.5.2";
  
  src = fetchurl {
    url = "mirror://savannah/libpipeline/${name}.tar.gz";
    hashOutput = false;
    sha256 = "fd59c649c1ae9d67604d1644f116ad4d297eaa66f838e3dfab96b41e85b059fb";
  };

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
      fullOpts = {
        pgpsigUrls = map (n: "${n}.asc") src.urls;
        pgpKeyFingerprint = "AC0A 4FF1 2611 B6FC CF01  C111 3935 87D9 7D86 500B";
      };
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
