{ stdenv
, fetchurl
, lib
, util-macros
}:

stdenv.mkDerivation rec {
  name = "compositeproto-0.4.2";

  src = fetchurl {
    url = "mirror://xorg/individual/proto/${name}.tar.bz2";
    sha256 = "049359f0be0b2b984a8149c966dd04e8c58e6eade2a4a309cf1126635ccd0cfc";
  };

  nativeBuildInputs = [
    util-macros
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--disable-strict-compilation"
  ];

  meta = with lib; {
    description = "X.Org Composite protocol headers";
    homepage = https://xorg.freedesktop.org;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
