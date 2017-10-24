{ stdenv
, fetchurl
, lib
}:

stdenv.mkDerivation rec {
  name = "apr-1.6.3";

  src = fetchurl {
    url = "mirror://apache/apr/${name}.tar.bz2";
    hashOutput = false;
    sha256 = "131f06d16d7aabd097fa992a33eec2b6af3962f93e6d570a9bd4d85e95993172";
  };

  preFixup = ''
    sed -i "s,$NIX_BUILD_TOP,/no-such-path,g" "$out"/bin/apr-1-config
  '';

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      pgpKeyFingerprints = [
        # Jeff Trawick
        "5B51 81C2 C0AB 13E5 9DA3  F7A3 EC58 2EB6 39FF 092C"
        # Nick Kew
        "B1B9 6F45 DFBD CCF9 7401  9235 193F 180A B55D 9977"
      ];
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with lib; {
    description = "The Apache Portable Runtime library";
    homepage = https://apr.apache.org/;
    license = licenses.asl20;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
