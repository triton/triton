{ stdenv
, fetchurl
, lib
}:

stdenv.mkDerivation rec {
  name = "hicolor-icon-theme-0.17";

  src = fetchurl {
    url = "https://icon-theme.freedesktop.org/releases/${name}.tar.xz";
    multihash = "QmfUENzAXVGA3pDibohPQgyPEUfXfs8NyUWY5Rtqbwutf1";
    sha256 = "317484352271d18cbbcfac3868eab798d67fff1b8402e740baa6ff41d588a9d8";
  };

  setupHook = ./setup-hook.sh;

  meta = with lib; {
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
