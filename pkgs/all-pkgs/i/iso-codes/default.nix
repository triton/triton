{ stdenv
, fetchurl
, lib

, gettext
, python3

, iso-codes
}:

stdenv.mkDerivation rec {
  name = "iso-codes-3.76";

  src = fetchurl {
    url = "https://pkg-isocodes.alioth.debian.org/downloads/${name}.tar.xz";
    multihash = "QmTzGpqWkWTkZ4K3TciUBb9KMFsCbgXdw5kFz6cCMtRzao";
    hashOutput = false;
    sha256 = "38ea8c1de7c07d5b4c9603ec65c238c155992a2e2ab0b02725d0926d1ad480c4";
  };

  nativeBuildInputs = [
    gettext
    python3
  ];

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprints = [
        "D1CB 8F39 BC5D ED24 C5D2  C78C 1302 F1F0 36EB EB19"
        "F972 A168 A270 3B34 CC23  E09F D4E5 EDAC C014 3D2D"
      ];
      inherit (src) urls outputHashAlgo outputHash;
    };
  };

  meta = with lib; {
    description = "Various ISO codes packaged as XML files";
    homepage = https://pkg-isocodes.alioth.debian.org/;
    license = licenses.free;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
