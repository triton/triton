{ stdenv
, fetchurl
, lib
, util-macros

, libx11
, libxfixes
, xorgproto
}:

stdenv.mkDerivation rec {
  name = "libXcomposite-0.4.4";

  src = fetchurl {
    url = "mirror://xorg/individual/lib/${name}.tar.bz2";
    sha256 = "ede250cd207d8bee4a338265c3007d7a68d5aca791b6ac41af18e9a2aeb34178";
  };

  nativeBuildInputs = [
    util-macros
  ];

  buildInputs = [
    libx11
    libxfixes
    xorgproto
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-selective-werror"
    "--disable-strict-compilation"
    "--without-xmlto"
  ];

  meta = with lib; {
    description = "Composite extension";
    homepage = https://xorg.freedesktop.org;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
