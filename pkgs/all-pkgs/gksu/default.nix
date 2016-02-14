{ stdenv
, fetchTritonPatch
, fetchurl
, intltool
, makeWrapper

, gconf
, gtk2
, libgksu
}:

stdenv.mkDerivation rec {
  name = "gksu-2.0.2";

  src = fetchurl {
    url = "http://people.debian.org/~kov/gksu/${name}.tar.gz";
    sha256 = "0npfanlh28daapkg25q4fncxd89rjhvid5fwzjaw324x0g53vpm1";
  };

  nativeBuildInputs = [
    intltool
    makeWrapper
  ];

  buildInputs = [
    gconf
    gtk2
    libgksu
  ];

  patches = [
    # https://savannah.nongnu.org/bugs/index.php?36127
    (fetchTritonPatch {
      rev = "fea1481e3a5255acae6df3f2bcba5fdcc0b433a0";
      file = "gksu/gksu-2.0.2-glib-2.31.patch";
      sha256 = "028fc1396265d51e90c209c4b3959e2f645f51c3104987ef08339821271d995c";
    })
  ];

  postPatch = ''
    sed -i gksu.desktop \
      -e 's|/usr/bin/x-terminal-emulator|-l gnome-terminal|g'
  '' + ''
    sed -i configure.ac \
      -e 's:AM_CONFIG_HEADER:AC_CONFIG_HEADERS:'
  '';

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-nls"
    "--enable-schemas-install"
    "--disable-gtk-doc"
    "--disable-nautilus-extension"
  ];

  meta = with stdenv.lib; {
    description = "A graphical frontend for libgksu";
    homepage = "http://www.nongnu.org/gksu/";
    license = licenses.gpl2;
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
