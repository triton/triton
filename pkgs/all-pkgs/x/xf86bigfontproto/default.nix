{ stdenv
, fetchurl
, lib
, util-macros
}:

stdenv.mkDerivation rec {
  name = "xf86bigfontproto-1.2.0";

  src = fetchurl {
    url = "mirror://xorg/individual/proto/${name}.tar.bz2";
    sha256 = "ba9220e2c4475f5ed2ddaa7287426b30089e4d29bd58d35fad57ba5ea43e1648";
  };

  nativeBuildInputs = [
    util-macros
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
