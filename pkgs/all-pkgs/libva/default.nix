{ stdenv
, fetchurl

, libdrm
, mesa
, mesa_noglu
, wayland
, xorg
}:

stdenv.mkDerivation rec {
  name = "libva-1.7.0";

  src = fetchurl {
    url = "https://www.freedesktop.org/software/vaapi/releases/libva/" +
          "${name}.tar.bz2";
    sha1Confirm = "e1e440da60b11986afb54fc130c7707f11827298";
    sha256 = "a689bccbcc81a66b458e448377f108c057d3eee44a2e21a23c92c549dc8bc95f";
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
    "--enable-drm"
    "--enable-x11"
    "--enable-glx"
    "--enable-egl"
    "--enable-wayland"
    #"--enable-dummy-driver"
    "--enable-largefile"
    "--with-drivers-path=${mesa_noglu.driverSearchPath}/lib/dri"
  ];

  preInstall = ''
    installFlagsArray+=("LIBVA_DRIVERS_PATH=$out/lib/dri")
  '';

  meta = with stdenv.lib; {
    description = "Video Acceleration (VA) API for Linux";
    homepage = http://www.freedesktop.org/wiki/Software/vaapi;
    license = licenses.mit;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
