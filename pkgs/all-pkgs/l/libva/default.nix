{ stdenv
, fetchurl

, libdrm
, mesa
, mesa_noglu
, wayland
, xorg
}:

stdenv.mkDerivation rec {
  name = "libva-1.7.3";

  src = fetchurl rec {
    url = "https://www.freedesktop.org/software/vaapi/releases/libva/${name}.tar.bz2";
    sha1Url = "${url}.sha1sum";
    multihash = "QmNcKVKfyvJEE6gka3okfTPRyTtAEVtqNhgKnc5Y8xTF27";
    sha256 = "22bc139498065a7950d966dbdb000cad04905cbd3dc8f3541f80d36c4670b9d9";
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
