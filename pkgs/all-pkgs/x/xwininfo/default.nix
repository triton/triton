{ stdenv
, fetchurl
, lib
, util-macros

, libx11
, libxcb
, xorgproto
}:

stdenv.mkDerivation rec {
  name = "xwininfo-1.1.3";

  src = fetchurl {
    url = "mirror://xorg/individual/app/${name}.tar.bz2";
    sha256 = "218eb0ea95bd8de7903dfaa26423820c523ad1598be0751d2d8b6a2c23b23ff8";
  };

  nativeBuildInputs = [
    util-macros
  ];

  buildInputs = [
    libx11
    libxcb
    xorgproto
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-rpath"
    "--disable-strict-compilation"
    #"--with-xcb-iccm"
  ];

  meta = with lib; {
    description = "Window information utility for X";
    homepage = https://xorg.freedesktop.org;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
