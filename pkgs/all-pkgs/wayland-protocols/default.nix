{ stdenv
, fetchurl

, wayland
}:

stdenv.mkDerivation rec {
  name = "wayland-protocols-1.3";

  src = fetchurl {
    url = "https://wayland.freedesktop.org/releases/${name}.tar.xz";
    sha256 = "6bcd0633fdf9225ef1c7d2831f542e947f7d79811c79fc37f57b2e5375ded82f";
  };

  buildInputs = [
    wayland
  ];

  meta = with stdenv.lib; {
    description = "Wayland protocol files";
    homepage = http://wayland.freedesktop.org/;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
