{ stdenv
, fetchurl
, lib
, util-macros

, libx11
, libxext
, xorgproto
}:

stdenv.mkDerivation rec {
  name = "libXScrnSaver-1.2.2";

  src = fetchurl {
    url = "mirror://xorg/individual/lib/${name}.tar.bz2";
    sha256 = "8ff1efa7341c7f34bcf9b17c89648d6325ddaae22e3904e091794e0b4426ce1d";
  };

  nativeBuildInputs = [
    util-macros
  ];

  buildInputs = [
    libx11
    libxext
    xorgproto
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-selective-werror"
    "--disable-strict-compilation"
    "--disable-lint-library"
    "--without-lint"
  ];

  meta = with lib; {
    description = "MIT-SCREEN-SAVER extension";
    homepage = https://xorg.freedesktop.org;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
