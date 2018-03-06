{ stdenv
, fetchurl
, lib
}:

stdenv.mkDerivation rec {
  name = "util-macros-1.19.2";

  src = fetchurl {
    url = "mirror://xorg/individual/util/${name}.tar.bz2";
    sha256 = "d7e43376ad220411499a79735020f9d145fdc159284867e99467e0d771f3e712";
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
        # Alan Coopersmith
        "4A19 3C06 D35E 7C67 0FA4  EF0B A2FB 9E08 1F2D 130E"
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
