{ stdenv
, autoconf
, automake
, fetchurl
, gettext
, intltool
, lib

, fontconfig
, fox
, freetype
, libpng
, libx11
, libxft
, libxrandr
}:

stdenv.mkDerivation rec {
  name = "xfe-1.42";

  src = fetchurl {
    url = "mirror://sourceforge/xfe/${name}.tar.gz";
    multihash = "QmX2wiGjkX27UoA83CYgqYm7Ph5NtfeUZEyoCKaFrTvB2f";
    sha256 = "a1e3e892584988c80b3a492f7b3cb78e1ee84d7148e6d1fc9d6054bbd8063bec";
  };

  nativeBuildInputs = [
    autoconf
    automake
    gettext
    intltool
  ];

  buildInputs = [
    fontconfig
    fox
    freetype
    libpng
    libx11
    libxft
    libxrandr
  ];

  postPatch = ''
    sed -i src/xfedefs.h \
      -e "s,/usr/share/xfe,$out/share/xfe,"
  '';

  configureFlags = [
    "--enable-nls"
    "--enable-threads=posix"
    #(enFlag "sn" (startup-notification != null) null)
    "--disable-debug"
    "--enable-minimal-flags"
    "--enable-release"
    "--with-x"
    "--with-xrandr"
  ];

  meta = with lib; {
    description = "MS-Explorer like file manager for X";
    homepage = "http://roland65.free.fr/xfe";
    license = licenses.gpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
