{ stdenv
, fetchurl

, libdrm
, mesa
, mesa_noglu
, wayland
, xorg
}:

stdenv.mkDerivation rec {
  name = "libva-1.7.2";

  src = fetchurl rec {
    url = "https://www.freedesktop.org/software/vaapi/releases/libva/${name}.tar.bz2";
    sha1Url = "${url}.sha1sum";
    multihash = "QmRP4umJUsNC35nHfC9ojUtvpx2N9ZV9uMMsdTChUaJwUr";
    sha256 = "5dd61cf16a5648b680e6146a58064e93be11bf4e65a9e4e30f1e9cb8ecfa2c13";
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
