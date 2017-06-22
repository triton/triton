{ stdenv
, fetchurl
, lib
, util-macros

, damageproto
, fixesproto
, libx11
, libxfixes
, xextproto
, xproto
}:

stdenv.mkDerivation rec {
  name = "libXdamage-1.1.4";

  src = fetchurl {
    url = "mirror://xorg/individual/lib/${name}.tar.bz2";
    sha256 = "7c3fe7c657e83547f4822bfde30a90d84524efb56365448768409b77f05355ad";
  };

  nativeBuildInputs = [
    util-macros
  ];

  buildInputs = [
    damageproto
    fixesproto
    libx11
    libxfixes
    xextproto
    xproto
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-selective-werror"
    "--disable-strict-compilation"
  ];

  meta = with lib; {
    description = "Damage extension";
    homepage = https://xorg.freedesktop.org;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
