{ stdenv
, fetchurl
, lib
, util-macros

, xorgproto
}:

stdenv.mkDerivation rec {
  name = "libXau-1.0.8";

  src = fetchurl {
    url = "mirror://xorg/individual/lib/${name}.tar.bz2";
    sha256 = "fdd477320aeb5cdd67272838722d6b7d544887dfe7de46e1e7cc0c27c2bea4f2";
  };

  nativeBuildInputs = [
    util-macros
  ];

  buildInputs = [
    xorgproto
  ];

  configureFlags = [
    "--enable-selective-werror"
    "--disable-strict-compilation"
    "--enable-xthreads"
    "--disable-lint-library"
    "--without-lint"
  ];

  meta = with lib; {
    description = "X.Org X authorization library";
    homepage = https://xorg.freedesktop.org;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
