{ stdenv
, fetchurl
, lib
, util-macros

, dmxproto
, libx11
, libxext
, xextproto
}:

stdenv.mkDerivation rec {
  name = "libdmx-1.1.3";

  src = fetchurl {
    url = "mirror://xorg/individual/lib/${name}.tar.bz2";
    sha256 = "c97da36d2e56a2d7b6e4f896241785acc95e97eb9557465fd66ba2a155a7b201";
  };

  nativeBuildInputs = [
    util-macros
  ];

  buildInputs = [
    dmxproto
    libx11
    libxext
    xextproto
  ];

  configureFlags = [
    "--enable-selective-werror"
  ];

  meta = with lib; {
    description = "X.org libdmx library";
    homepage = https://xorg.freedesktop.org;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
