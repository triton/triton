{ stdenv
, fetchurl
, python

, glib
}:

stdenv.mkDerivation rec {
  name = "libqmi-1.16.0";

  src = fetchurl {
    url = "https://www.freedesktop.org/software/libqmi/${name}.tar.xz";
    sha256 = "7ab6bb47fd23bf4d3fa17424e40ea5552d08b19e5ee4f125f21f316c8086ba2a";
  };

  nativeBuildInputs = [
    python
  ];

  buildInputs = [
    glib
  ];

  preBuild = ''
    patchShebangs .
  '';

  meta = with stdenv.lib; {
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
