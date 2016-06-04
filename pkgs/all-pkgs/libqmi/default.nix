{ stdenv
, fetchurl
, python

, glib
}:

stdenv.mkDerivation rec {
  name = "libqmi-1.14.2";

  src = fetchurl {
    url = "https://www.freedesktop.org/software/libqmi/${name}.tar.xz";
    sha256 = "6283b80aea1b2721523e5229087764b4d6a1c9f53488690fa16a11adff4a0040";
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
