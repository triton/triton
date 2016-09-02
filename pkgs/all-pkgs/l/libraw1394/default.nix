{ stdenv
, fetchurl
}:

let
  version = "2.1.2";

  baseFileUrls = [
    "mirror://kernel/linux/libs/ieee1394/libraw1394-${version}"
  ];
in
stdenv.mkDerivation rec {
  name = "libraw1394-${version}";

  src = fetchurl {
    urls = map (n: "${n}.tar.xz") baseFileUrls;
    hashOutput = false;
    sha256 = "03ccc69761d22c7deb1127fc301010dd13e70e44bb7134b8ff0d07590259a55e";
  };

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.tar.sign") baseFileUrls;
      pgpDecompress = true;
      pgpKeyFingerprint = "955C 0098 E5C4 6EF9 A152  4814 79F3 6FB2 545D 79D0";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    homepage = "https://ieee1394.wiki.kernel.org/index.php/Libraries#libraw1394";
    license = licenses.lgpl21Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
