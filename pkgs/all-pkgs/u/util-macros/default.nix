{ stdenv
, fetchurl
, lib
}:

stdenv.mkDerivation rec {
  name = "util-macros-1.19.0";

  src = fetchurl {
    url = "mirror://xorg/individual/util/${name}.tar.bz2";
    hashOutput = false;
    sha256 = "2835b11829ee634e19fa56517b4cfc52ef39acea0cd82e15f68096e27cbed0ba";
  };

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprints = [ ];
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "";
    homepage = http://xorg.freedesktop.org;
    license = licenses.free;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
