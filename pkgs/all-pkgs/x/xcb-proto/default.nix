{ stdenv
, fetchurl
, lib

, python
}:

stdenv.mkDerivation rec {
  name = "xcb-proto-1.12";

  src = fetchurl {
    url = "mirror://xorg/individual/xcb/${name}.tar.bz2";
    sha256 = "5922aba4c664ab7899a29d92ea91a87aa4c1fc7eb5ee550325c3216c480a4906";
  };

  nativeBuildInputs = [
    python
  ];

  meta = with lib; {
    description = "X C-language Bindings protocol headers";
    homepage = https://xcb.freedesktop.org;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
