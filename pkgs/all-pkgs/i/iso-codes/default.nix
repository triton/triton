{ stdenv
, fetchurl
, lib

, gettext
, python3

, iso-codes
}:

let
  tarHash = "ef8de8bc12e0512d26ed73436a477871";
  sigHash = "776a6ee6851f12adafd5430d8ebce693";
in
stdenv.mkDerivation rec {
  name = "iso-codes-3.79";

  src = fetchurl {
    urls = [
      "https://salsa.debian.org/iso-codes-team/iso-codes/uploads/${tarHash}/${name}.tar.xz"
      "https://ftp.osuosl.org/pub/blfs/conglomeration/iso-codes/${name}.tar.xz"
    ];
    hashOutput = false;
    sha256 = "cbafd36cd4c588a254c0a5c42e682190c3784ceaf2a098da4c9c4a0cbc842822";
  };

  nativeBuildInputs = [
    gettext
    python3
  ];

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      pgpsigUrl = "https://salsa.debian.org/iso-codes-team/iso-codes/uploads/${sigHash}/${name}.tar.xz.sig";
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
