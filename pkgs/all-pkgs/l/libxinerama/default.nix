{ stdenv
, fetchurl
, lib
, util-macros

, libx11
, libxext
, xorgproto
}:

stdenv.mkDerivation rec {
  name = "libXinerama-1.1.3";

  src = fetchurl {
    url = "mirror://xorg/individual/lib/${name}.tar.bz2";
    sha256 = "7a45699f1773095a3f821e491cbd5e10c887c5a5fce5d8d3fced15c2ff7698e2";
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
    "--enable-selective-werror"
    "--disable-strict-compilation"
    #"--enable-malloc0returnsnull"
    "--without-list"
  ];

  meta = with lib; {
    description = "Xinerama protocol library";
    homepage = https://xorg.freedesktop.org;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
