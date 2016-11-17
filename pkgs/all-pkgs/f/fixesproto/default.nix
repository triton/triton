{ stdenv
, fetchurl
, lib
, util-macros

, xextproto
}:

stdenv.mkDerivation rec {
  name = "fixesproto-5.0";

  src = fetchurl {
    url = "mirror://xorg/individual/proto/${name}.tar.bz2";
    sha256 = "ba2f3f31246bdd3f2a0acf8bd3b09ba99cab965c7fb2c2c92b7dc72870e424ce";
  };

  nativeBuildInputs = [
    util-macros
  ];

  buildInputs = [
    xextproto
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--disable-strict-compilation"
  ];

  meta = with lib; {
    description = "X.Org Fixes protocol headers";
    homepage = https://xorg.freedesktop.org;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
