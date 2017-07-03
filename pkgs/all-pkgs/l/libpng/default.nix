{ stdenv
, fetchurl

, zlib
}:

let
  version = "1.6.30";
in
stdenv.mkDerivation rec {
  name = "libpng-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/libpng/libpng16/${version}/${name}.tar.xz";
    hashOutput = false;
    sha256 = "267c332ffff70cc599d3929207869f698798f1df143aa5f9597b007c14353666";
  };

  buildInputs = [
    zlib
  ];

  patches = [
    (fetchurl {
      url = "mirror://sourceforge/libpng-apng/libpng16/1.6.30/libpng-1.6.30-apng.patch.gz";
      sha256 = "1a6359b1fa7855ed8afcf11be57725093d29cc7ee921c8e030c59d63c565d91a";
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
