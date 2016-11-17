{ stdenv
, fetchurl
, lib
, util-macros
}:

stdenv.mkDerivation rec {
  name = "dri3proto-1.0";

  src = fetchurl {
    url = "mirror://xorg/individual/proto/${name}.tar.bz2";
    sha256 = "01be49d70200518b9a6b297131f6cc71f4ea2de17436896af153226a774fc074";
  };

  nativeBuildInputs = [
    util-macros
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-selective-werror"
    "--disable-strict-compilation"
  ];

  meta = with lib; {
    description = "X.Org DRI3 protocol specification and Xlib/Xserver headers";
    homepage = https://xorg.freedesktop.org;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
