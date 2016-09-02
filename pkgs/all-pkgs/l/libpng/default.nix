{ stdenv
, fetchurl

, zlib
}:

let
  version = "1.6.25";
in
stdenv.mkDerivation rec {
  name = "libpng-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/libpng/libpng-${version}.tar.xz";
    hashOutput = false;
    multihash = "QmZAxyJJzj8o9Sg1HMZqZ8GGMRKFBvoguu1Wr56ztdmuaF";
    sha256 = "09fe8d8341e8bfcfb3263100d9ac7ea2155b28dd8535f179111c1672ac8d8811";
  };

  buildInputs = [
    zlib
  ];

  patchFlags = "-p0";

  patches = [
    (fetchurl {
      url = "mirror://sourceforge/libpng-apng/libpng-1.6.25-apng.patch.gz";
      multihash = "QmRsNvEsh1W6XwdGT6Ye2bGc7A7KERDozrxpR9gsFDwXaC";
      sha256 = "e264d917d84872f01af3acf9666471a9bf64b75558b4b35236fef1e23c2a094f";
    })
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrl = map (n: "${n}.asc") src.urls;
      pgpKeyFingerprint = "8048 643B A2C8 40F4 F92A  195F F549 84BF A16C 640F";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    description = "The official reference implementation for the PNG file format with animation patch";
    homepage = http://www.libpng.org/pub/png/libpng.html;
    license = licenses.libpng;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
