{ stdenv
, fetchurl

, zlib
}:

let
  version = "1.6.24";
in
stdenv.mkDerivation rec {
  name = "libpng-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/libpng/libpng-${version}.tar.xz";
    allowHashOutput = false;
    multihash = "QmVzBnjR7i7XKimSxHJvhbWCqhjLbKRhUaDvfMzeiCs7NN";
    sha256 = "7932dc9e5e45d55ece9d204e90196bbb5f2c82741ccb0f7e10d07d364a6fd6dd";
  };

  buildInputs = [
    zlib
  ];

  patches = [
    (fetchurl {
      url = "mirror://sourceforge/libpng-apng/libpng-1.6.23-apng.patch.gz";
      multihash = "QmUmLE2SXhvrJcJbn9d3EChfTp36CVq3YYhdcKCXucdSC5";
      sha256 = "08906e0639a953f6be2d47857661cbdf04dcab93d3bf9f8cb0f7675567b07ad3";
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
