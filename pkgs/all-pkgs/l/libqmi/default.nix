{ stdenv
, fetchurl
, lib
, python

, glib
, libgudev
, libmbim
}:

stdenv.mkDerivation rec {
  name = "libqmi-1.20.0";

  src = fetchurl {
    url = "https://www.freedesktop.org/software/libqmi/${name}.tar.xz";
    multihash = "QmZZs9nTRFqkwNHcjxU2XJuWJAF9okzF9PxBxEcnRSU93y";
    sha256 = "21428cd3749c56246565123f707fee51238651a22c60bdc85ebce97388626eb4";
  };

  nativeBuildInputs = [
    python
  ];

  buildInputs = [
    glib
    libgudev
    libmbim
  ];

  preBuild = ''
    patchShebangs .
  '';

  meta = with lib; {
    homepage = http://www.freedesktop.org/wiki/Software/libqmi/;
    description = "Modem protocol helper library";
    license = licenses.gpl2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
