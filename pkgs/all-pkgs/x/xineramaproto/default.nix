{ stdenv
, fetchurl
, lib

, util-macros
}:

stdenv.mkDerivation rec {
  name = "xineramaproto-1.2.1";

  src = fetchurl {
    url = "mirror://xorg/individual/proto/${name}.tar.bz2";
    sha256 = "977574bb3dc192ecd9c55f59f991ec1dff340be3e31392c95deff423da52485b";
  };

  nativeBuildInputs = [
    util-macros
  ];

  configureFlags = [
    "--disable-maintainer-mode"
  ];

  meta = with lib; {
    description = "X.Org Xinerama protocol headers";
    homepage = http://xorg.freedesktop.org;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
