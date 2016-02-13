{ stdenv
, fetchurl
, python

, glib
}:

stdenv.mkDerivation rec {
  name = "libqmi-1.12.8";

  src = fetchurl {
    url = "http://www.freedesktop.org/software/libqmi/${name}.tar.xz";
    sha256 = "19w2zkm5xl6i3vm1xhjjclks4awas17gfbb2k5y66gwnkiykjfnj";
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
    platforms = platforms.linux;
    license = licenses.gpl2;
    maintainers = with maintainers; [ wkennington ];
  };
}
