{ stdenv
, fetchurl

, glib
, libgudev
, udev
}:

stdenv.mkDerivation rec {
  name = "libwacom-0.18";

  src = fetchurl {
    url = "mirror://sourceforge/linuxwacom/libwacom/${name}.tar.bz2";
    sha256 = "08mplxbgmdvpk1azh35y7iqz96jaf8bdibjjm2nz5hhfs6la5gvi";
  };

  postPatch =
  /* Disable docs */ ''
    sed -i Makefile.in \
      -e 's:^\(SUBDIRS = .* \)doc:\1:'
  '';

  buildInputs = [
    glib
    libgudev
    udev
  ];

  meta = with stdenv.lib; {
    description = "Library for identifying Wacom tablets and features";
    homepage = http://sourceforge.net/projects/linuxwacom/;
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };

}
