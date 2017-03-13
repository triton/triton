{ stdenv
, fetchurl
, lib
}:

stdenv.mkDerivation rec {
  name = "util-macros-1.19.1";

  src = fetchurl {
    url = "mirror://xorg/individual/util/${name}.tar.bz2";
    sha256 = "18d459400558f4ea99527bc9786c033965a3db45bf4c6a32eefdc07aa9e306a6";
  };

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      failEarly = true;
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprints = [
        # Matt Turner
        "3BB6 39E5 6F86 1FA2 E865  0569 0FDD 682D 974C A72A"
      ];
    };
  };

  meta = with lib; {
    description = "X.Org autotools utility macros";
    homepage = https://xorg.freedesktop.org;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
