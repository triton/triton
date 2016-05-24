{ stdenv
, fetchurl

, glib
, libgudev
, systemd_lib
}:

stdenv.mkDerivation rec {
  name = "libwacom-0.19";

  src = fetchurl {
    url = "mirror://sourceforge/linuxwacom/libwacom/${name}.tar.bz2";
    sha256 = "620d88cd85d118107c69db094c07284ead2342048cc0e9a5f16eb951a8b855ff";
  };

  postPatch =
  /* Disable docs */ ''
    sed -i Makefile.in \
      -e 's:^\(SUBDIRS = .* \)doc:\1:'
  '';

  buildInputs = [
    glib
    libgudev
    systemd_lib
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
