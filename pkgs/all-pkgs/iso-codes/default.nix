{ stdenv
, fetchurl

, gettext
, python

, iso-codes
}:

stdenv.mkDerivation rec {
  name = "iso-codes-3.67";

  src = fetchurl {
    url = "http://pkg-isocodes.alioth.debian.org/downloads/${name}.tar.xz";
    sha256 = "603f51e0b5ebd762b66d9aa3bd0d9a33af1aaedae88caaaf196fcc5bb4abf00c";
  };

  nativeBuildInputs = [
    gettext
    python
  ];

  postPatch = ''
    patchShebangs .
  '';

  passthru = {
    srcVerified = fetchurl rec {
      failEarly = true;
      url = "http://pkg-isocodes.alioth.debian.org/downloads/${name}.tar.xz";
      pgpsigUrl = "${url}.sig";
      pgpKeyFingerprints = [
        "D1CB 8F39 BC5D ED24 C5D2  C78C 1302 F1F0 36EB EB19"
        "F972 A168 A270 3B34 CC23  E09F D4E5 EDAC C014 3D2D"
      ];
      inherit (src) outputHashAlgo outputHash;
    };
  };

  meta = with stdenv.lib; {
    description = "Various ISO codes packaged as XML files";
    homepage = http://pkg-isocodes.alioth.debian.org/;
    license = licenses.free;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
