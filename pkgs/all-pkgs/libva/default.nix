{ stdenv
, fetchurl

, libdrm
, mesa
, mesa_noglu
, wayland
, xorg
}:

with {
  inherit (stdenv.lib)
    enFlag;
};

stdenv.mkDerivation rec {
  name = "libva-1.6.2";

  src = fetchurl {
    url = "http://www.freedesktop.org/software/vaapi/releases/libva/" +
          "${name}.tar.bz2";
    sha256 = "1l4bij21shqbfllbxicmqgmay4v509v9hpxyyia9wm7gvsfg05y4";
  };

  buildInputs = [
    libdrm
    mesa
    wayland
    xorg.libX11
    xorg.libXext
    xorg.libXfixes
  ];

  configureFlags = [
    (enFlag "drm" (libdrm != null) null)
    (enFlag "x11" (xorg.libX11 != null && mesa != null) null)
    (enFlag "glx" (mesa != null) null)
    (enFlag "egl" (mesa != null) null)
    (enFlag "wayland" (wayland != null && mesa != null) null)
    #"--enable-dummy-driver"
    "--enable-largefile"
    "--with-drivers-path=${mesa_noglu.driverLink}/lib/dri"
  ];

  preInstall = ''
    installFlagsArray+=("LIBVA_DRIVERS_PATH=$out/lib/dri")
  '';

  meta = with stdenv.lib; {
  description = "Video Acceleration (VA) API for Linux";
    homepage = http://www.freedesktop.org/wiki/Software/vaapi;
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
