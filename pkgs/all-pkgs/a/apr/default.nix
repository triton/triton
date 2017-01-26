{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "apr-1.5.2";

  src = fetchurl {
    url = "mirror://apache/apr/${name}.tar.bz2";
    hashOutput = false;
    sha256 = "0ypn51xblix5ys9xy7da3ngdydip0qqh9rdq8nz54w9aq8lys0vx";
  };

  preFixup = ''
    sed -i "s,$NIX_BUILD_TOP,/no-such-path,g" "$out"/bin/apr-1-config
  '';

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      pgpKeyFingerprint = "5B51 81C2 C0AB 13E5 9DA3  F7A3 EC58 2EB6 39FF 092C";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
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
