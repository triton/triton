{ stdenv
, fetchurl
, lib
, util-macros

, fixesproto
, libx11
, libxfixes
, libxrender
, xproto
}:

stdenv.mkDerivation rec {
  name = "libXcursor-1.1.14";

  src = fetchurl {
    url = "mirror://xorg/individual/lib/${name}.tar.bz2";
    sha256 = "9bc6acb21ca14da51bda5bc912c8955bc6e5e433f0ab00c5e8bef842596c33df";
  };

  nativeBuildInputs = [
    util-macros
  ];

  buildInputs = [
    fixesproto
    libx11
    libxfixes
    libxrender
    xproto
  ];

  configureFlags = [
    "--enable-maintainer-mode"
    "--without-lint"
  ];

  meta = with lib; {
    description = "X.org libXcursor library";
    homepage = https://xorg.freedesktop.org;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
