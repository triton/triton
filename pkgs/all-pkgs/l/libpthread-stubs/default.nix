{ stdenv
, fetchurl
, lib
}:

stdenv.mkDerivation rec {
  name = "libpthread-stubs-0.4";

  src = fetchurl {
    url = "mirror://xorg/individual/xcb/${name}.tar.bz2";
    sha256 = "e4d05911a3165d3b18321cc067fdd2f023f06436e391c6a28dff618a78d2e733";
  };

  meta = with lib; {
    description = "Pthread functions stubs for platforms missing them";
    homepage = https://xorg.freedesktop.org;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
