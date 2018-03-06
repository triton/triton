{ stdenv
, fetchurl
, lib
, util-macros

, libx11
, xorgproto
}:

stdenv.mkDerivation rec {
  name = "xrefresh-1.0.5";

  src = fetchurl {
    url = "mirror://xorg/individual/app/${name}.tar.bz2";
    sha256 = "3213671b0a8a9d1e8d1d5d9e3fd86842c894dd9acc1be2560eda50bc1fb791d6";
  };

  nativeBuildInputs = [
    util-macros
  ];

  buildInputs = [
    libx11
    xorgproto
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-selective-werror"
    "--disable-strict-compilation"
  ];

  meta = with lib; {
    description = "Refresh all or part of an X screen";
    homepage = https://xorg.freedesktop.org;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
