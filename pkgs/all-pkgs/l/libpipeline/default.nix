{ stdenv
, fetchurl
}:
 
stdenv.mkDerivation rec {
  name = "libpipeline-1.5.1";
  
  src = fetchurl {
    url = "mirror://savannah/libpipeline/${name}.tar.gz";
    hashOutput = false;
    sha256 = "d633706b7d845f08b42bc66ddbe845d57e726bf89298e2cee29f09577e2f902f";
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
