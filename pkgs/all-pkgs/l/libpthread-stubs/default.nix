{ stdenv
, fetchurl
, lib
}:

stdenv.mkDerivation rec {
  name = "libpthread-stubs-0.3";

  src = fetchurl {
    url = "mirror://xorg/individual/xcb/${name}.tar.bz2";
    sha256 = "35b6d54e3cc6f3ba28061da81af64b9a92b7b757319098172488a660e3d87299";
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
