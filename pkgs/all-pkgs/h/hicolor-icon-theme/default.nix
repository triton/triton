{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "hicolor-icon-theme-0.15";

  src = fetchurl {
    url = "https://icon-theme.freedesktop.org/releases/${name}.tar.xz";
    sha256 = "9cc45ac3318c31212ea2d8cb99e64020732393ee7630fa6c1810af5f987033cc";
  };

  setupHook = ./setup-hook.sh;

  meta = with stdenv.lib; {
    description = "Default fallback theme used by the icon theme specification";
    homepage = http://icon-theme.freedesktop.org/releases/;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
