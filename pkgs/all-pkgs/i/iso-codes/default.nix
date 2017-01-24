{ stdenv
, fetchurl

, gettext
, python3

, iso-codes
}:

stdenv.mkDerivation rec {
  name = "iso-codes-3.74";

  src = fetchurl {
    url = "https://pkg-isocodes.alioth.debian.org/downloads/${name}.tar.xz";
    multihash = "QmXrvkNV4eCdD8pyDRQYd8fPStrN77dWQ7hBNUhDJcBgDC";
    hashOutput = false;
    sha256 = "21f4f3cea8fe09f5b53784522303a0e1e7d083964ecaf1c75b1441d4d9ec6aee";
  };

  nativeBuildInputs = [
    gettext
    python3
  ];

  postPatch = ''
    patchShebangs .
  '';

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

  meta = with stdenv.lib; {
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
