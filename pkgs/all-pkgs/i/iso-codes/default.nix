{ stdenv
, fetchurl

, gettext
, python

, iso-codes
}:

stdenv.mkDerivation rec {
  name = "iso-codes-3.68";

  src = fetchurl {
    urls = [
      "http://pkg-isocodes.alioth.debian.org/downloads/${name}.tar.xz"
      "mirror://gentoo/distfiles/${name}.tar.xz"
    ];
    allowHashOutput = false;
    sha256 = "5881cf7caa5adfffb14ade99138949324c28a277babe8d07dafbff521acef9d1";
  };

  nativeBuildInputs = [
    gettext
    python
  ];

  postPatch = ''
    patchShebangs .
  '';

  passthru = {
    srcVerification = fetchurl rec {
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
