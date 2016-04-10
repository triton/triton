{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "hicolor-icon-theme-0.15";

  src = fetchurl {
    url = "https://icon-theme.freedesktop.org/releases/${name}.tar.xz";
    sha256 = "1k9fj0lb9b44inb5q5m04910x5nfkzrxl3ys9ckihqrixzk0dvbv";
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
