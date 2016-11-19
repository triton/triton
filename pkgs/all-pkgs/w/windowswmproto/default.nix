{ stdenv
, fetchurl
, lib
, util-macros
}:

stdenv.mkDerivation rec {
  name = "windowswmproto-1.0.4";

  src = fetchurl {
    url = "mirror://xorg/individual/proto/${name}.tar.bz2";
    sha256 = "c05bb0edb627554fe97aa1516aed44accf6566b1db0e50332689a24afcebd26b";
  };

  nativeBuildInputs = [
    util-macros
  ];

  configureFlags = [
    "--disable-strict-compilation"
  ];

  meta = with lib; {
    description = "";
    homepage = https://xorg.freedesktop.org;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
