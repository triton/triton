{ stdenv
, autoreconfHook
, fetchTritonPatch
, fetchurl
, gettext
, intltool
, makeWrapper

, gconf
, gnome
, gtk2
, libgnome-keyring
, libgtop
, libstartup_notification
#, sudo
, xorg
}:

stdenv.mkDerivation rec {
  name = "libgksu-${version}";
  version = "2.0.12";

  src = fetchurl {
    url = "https://people.debian.org/~kov/gksu/${name}.tar.gz";
    sha256 = "1brz9j3nf7l2gd3a5grbp0s3nksmlrp6rxmgp5s6gjvxcb1wzy92";
  };

  nativeBuildInputs = [
    autoreconfHook
    gettext
    intltool
    makeWrapper
  ];

  buildInputs = [
    gconf
    gtk2
    gnome.libglade
    libgnome-keyring
    libgtop
    libstartup_notification
  ];

  patches = [
    # Fix compilation on bsd
    (fetchTritonPatch {
      rev = "e4d5d194fbd0847d24c3e1c1930091a3a3bd7df4";
      file = "libgksu/libgksu-2.0.0-fbsd.patch";
      sha256 = "bf0343df8e316ac227da7c40a889dd5128da081a640c187dfb743b4f213c3792";
    })
    # Fix wrong usage of LDFLAGS, gentoo bug #226837
    (fetchTritonPatch {
      rev = "e4d5d194fbd0847d24c3e1c1930091a3a3bd7df4";
      file = "libgksu/libgksu-2.0.7-libs.patch";
      sha256 = "62d1d576bd8e4b07494a788d6760463ee2090e341dae5113d5f763a3549f6b6a";
    })
    # Use po/LINGUAS
    (fetchTritonPatch {
      rev = "e4d5d194fbd0847d24c3e1c1930091a3a3bd7df4";
      file = "libgksu/libgksu-2.0.7-polinguas.patch";
      sha256 = "f360bbd003492e7bc7818f97988ff3af81a14c4278b1f788b0b919f743d7ee8f";
    })
    # Don't forkpty; gentoo bug #298289
    (fetchTritonPatch {
      rev = "e4d5d194fbd0847d24c3e1c1930091a3a3bd7df4";
      file = "libgksu/libgksu-2.0.12-revert-forkpty.patch";
      sha256 = "e75597115bdc7c30ee223d73f5c071d7cceffd04fbf2798d1aa17920fae865dd";
    })
    # Make this gmake-3.82 compliant, gentoo bug #333961
    (fetchTritonPatch {
      rev = "e4d5d194fbd0847d24c3e1c1930091a3a3bd7df4";
      file = "libgksu/libgksu-2.0.12-fix-make-3.82.patch";
      sha256 = "f70ed3aa37b2e7523ac5e3260be36dc3ff911aa6923d82520ee9b4dc502a7694";
    })
    # Do not build test programs that are never executed,
    # also fixes gentoo bug #367397 (underlinking issues).
    (fetchTritonPatch {
      rev = "e4d5d194fbd0847d24c3e1c1930091a3a3bd7df4";
      file = "libgksu/libgksu-2.0.12-notests.patch";
      sha256 = "6cac450d0e3d8950c25fec078cc41478138fd14afe3492e96f7b889178725707";
    })
    # Fix automake-1.11.2 compatibility, gentoo bug #397411
    (fetchTritonPatch {
      rev = "e4d5d194fbd0847d24c3e1c1930091a3a3bd7df4";
      file = "libgksu/libgksu-2.0.12-automake-1.11.2.patch";
      sha256 = "8d6573025758e5f5c569963fab2d99f406ea50fb055bf06693868ba976c5dd66";
    })
	];

  postPatch =
    /* gentoo bug #467026 */ ''
      sed -i configure.ac \
        -e 's:AM_CONFIG_HEADER:AC_CONFIG_HEADERS:'
    '' +
    /* Fix some binary paths */ ''
      sed -i  libgksu/gksu-run-helper.c \
        -e 's|/usr/bin/xauth|${xorg.xauth}/bin/xauth|g'
      sed -i libgksu/libgksu.c \
        -e 's|/usr/bin/xauth|${xorg.xauth}/bin/xauth|g' \
        -e 's|/usr/bin/sudo|/var/setuid-wrappers/sudo|g' \
        -e 's|/bin/su\([^d]\)|/var/setuid-wrappers/su\1|g'
    '' + ''
      touch NEWS README
    '';

  preConfigure = ''
    intltoolize --force --copy --automake
  '';

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-schemas-install"
    "--enable-nls"
    "--disable-gtk-doc"
  ];

  preFixup = ''
    wrapProgram "$out/bin/gksu-properties" \
      --set GDK_PIXBUF_MODULE_FILE "$GDK_PIXBUF_MODULE_FILE"
  '';

  meta = with stdenv.lib; {
    description = "A library for integration of su into applications";
    homepage = http://www.nongnu.org/gksu/;
    license = licenses.lgpl2;
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
