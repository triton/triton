{ stdenv
, fetchurl
, lib
, util-macros

, libx11
, libxext
, libxt
, xorgproto
}:

stdenv.mkDerivation rec {
  name = "libXmu-1.1.2";

  src = fetchurl {
    url = "mirror://xorg/individual/lib/${name}.tar.bz2";
    sha256 = "756edc7c383254eef8b4e1b733c3bf1dc061b523c9f9833ac7058378b8349d0b";
  };

  nativeBuildInputs = [
    util-macros
  ];

  buildInputs = [
    libx11
    libxext
    libxt
    xorgproto
  ];

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
